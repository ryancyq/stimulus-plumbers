import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import CalendarController from '../../../src/controllers/calendar_controller';
import CalendarTurboController from '../../../src/controllers/calendar_turbo_controller';
import { monthGrid, parseDateKey } from '../../../src/date';
import { flush, startApplication } from '../../support/stimulus';

describe('CalendarController', () => {
  let application;
  let consoleError;
  let consoleWarn;

  // Server-shaped month markup (sp_calendar): hidden adjacent days are empty cells.
  const monthMarkup = ({ displayed = '2026-09-15', focus = '2026-09-15', selected = '', disabled = [] } = {}) => {
    const month = displayed.slice(0, 7);
    const rows = monthGrid(parseDateKey(displayed), 0)
      .map((week) => {
        const cells = week.map((key) => {
          if (!key.startsWith(month)) return '<td></td>';
          const aria = disabled.includes(key) ? ' aria-disabled="true"' : '';
          return `<td role="gridcell" aria-selected="${key === selected}">
            <button type="button" tabindex="${key === focus ? 0 : -1}"${aria}
                    data-calendar-target="day" data-date="${key}">${Number(key.slice(8))}</button></td>`;
        });
        return `<tr>${cells.join('')}</tr>`;
      })
      .join('');
    return `<table role="grid" data-calendar-target="grid" data-displayed="${displayed}" data-view="month"
                   data-action="keydown->calendar#onKeydown click->calendar#onClick"><tbody>${rows}</tbody></table>`;
  };

  const decadeMarkup = (focus = '2026-01-01') => {
    const years = Array.from({ length: 12 }, (_, index) => 2019 + index);
    const rows = [0, 4, 8].map(
      (start) =>
        `<tr>${years
          .slice(start, start + 4)
          .map(
            (year) =>
              `<td role="gridcell"><a href="#" tabindex="${`${year}-01-01` === focus ? 0 : -1}"
                 data-calendar-target="period" data-date="${year}-01-01">${year}</a></td>`
          )
          .join('')}</tr>`
    );
    return `<table role="grid" data-calendar-target="grid" data-displayed="2026-01-01" data-view="decade"
                   data-action="keydown->calendar#onKeydown click->calendar#onClick"><tbody>${rows.join('')}</tbody></table>`;
  };

  const render = async ({
    grid = monthMarkup(),
    attrs = 'data-calendar-selectable-value="true"',
    form = false,
  } = {}) => {
    const section = `<section id="root" data-controller="calendar" data-calendar-navigation-value="turbo" ${attrs}>
        <div role="status" data-calendar-target="status"></div>${grid}</section>`;
    document.body.innerHTML = form ? `<form id="form">${section}</form>` : section;
    const root = document.querySelector('#root');
    await vi.waitUntil(() => application.getControllerForElementAndIdentifier(root, 'calendar'));
    return { root, controller: application.getControllerForElementAndIdentifier(root, 'calendar') };
  };

  const day = (key) => document.querySelector(`[data-date="${key}"]`);
  const key = (target, name, init = {}) => {
    const event = new KeyboardEvent('keydown', { key: name, bubbles: true, cancelable: true, ...init });
    target.dispatchEvent(event);
    return event;
  };
  const tabStops = () => [...document.querySelectorAll('[tabindex="0"]')].map((element) => element.dataset.date);

  beforeEach(() => {
    application = startApplication({ calendar: CalendarController, 'calendar-turbo': CalendarTurboController });
    consoleError = vi.spyOn(console, 'error').mockImplementation(() => {});
    consoleWarn = vi.spyOn(console, 'warn').mockImplementation(() => {});
  });

  afterEach(() => {
    document.body.innerHTML = '';
    consoleError.mockRestore();
    consoleWarn.mockRestore();
  });

  describe('Tab stop', () => {
    it('keeps the server-rendered Tab stop', async () => {
      await render();

      expect(tabStops()).toEqual(['2026-09-15']);
      expect(consoleWarn).not.toHaveBeenCalled();
    });

    it('repairs markup without exactly one Tab stop, preferring the selection', async () => {
      await render({
        grid: monthMarkup({ focus: null, selected: '2026-09-20' }),
        attrs: 'data-calendar-selectable-value="true" data-calendar-selected-value="2026-09-20"',
      });

      expect(tabStops()).toEqual(['2026-09-20']);
      expect(consoleWarn).toHaveBeenCalledOnce();
    });

    it('reports cells without a date key', async () => {
      await render({ grid: monthMarkup().replace('data-date="2026-09-03"', 'data-date="Sept 3"') });

      expect(consoleError).toHaveBeenCalledWith(expect.stringContaining('data-date'));
    });
  });

  describe('keyboard', () => {
    it.each([
      ['ArrowRight', {}, '2026-09-16'],
      ['ArrowLeft', {}, '2026-09-14'],
      ['ArrowDown', {}, '2026-09-22'],
      ['ArrowUp', {}, '2026-09-08'],
      ['Home', {}, '2026-09-13'],
      ['End', {}, '2026-09-19'],
    ])('%s moves focus and the Tab stop within the month', async (name, init, target) => {
      await render();
      day('2026-09-15').focus();

      expect(key(day('2026-09-15'), name, init).defaultPrevented).toBe(true);
      expect(document.activeElement).toBe(day(target));
      expect(tabStops()).toEqual([target]);
    });

    it('keeps Home and End within the days shown in the week', async () => {
      await render({ grid: monthMarkup({ focus: '2026-09-03' }) });

      key(day('2026-09-03'), 'Home');
      expect(document.activeElement).toBe(day('2026-09-01'));

      key(day('2026-09-01'), 'End');
      expect(document.activeElement).toBe(day('2026-09-05'));
    });

    it('does not commit while moving focus', async () => {
      await render();

      key(day('2026-09-15'), 'ArrowRight');

      expect(document.querySelector('[aria-selected="true"]')).toBeNull();
    });

    it('leaves keys it does not handle alone', async () => {
      await render();

      expect(key(day('2026-09-15'), 'Tab').defaultPrevented).toBe(false);
      expect(key(day('2026-09-15'), 'ArrowRight', { ctrlKey: true }).defaultPrevented).toBe(false);
    });

    it.each([
      ['PageDown', {}, '2026-10-15'],
      ['PageUp', {}, '2026-08-15'],
      ['PageDown', { shiftKey: true }, '2027-09-15'],
      ['ArrowUp', {}, '2026-08-29'],
    ])('%s past the month requests navigation with the intended date', async (name, init, target) => {
      const { root } = await render({ grid: monthMarkup({ displayed: '2026-09-15', focus: '2026-09-05' }) });
      const from = name === 'ArrowUp' ? '2026-09-05' : '2026-09-15';
      day(from).tabIndex = 0;
      const navigate = vi.fn();
      root.addEventListener('calendar:navigate', (event) => navigate(event.detail));

      key(day(from), name, init);

      expect(navigate).toHaveBeenCalledWith(
        expect.objectContaining({ from: '2026-09-15', to: target, focusDate: target, view: 'month' })
      );
    });

    it('clamps month paging to the last day', async () => {
      const { root } = await render({ grid: monthMarkup({ displayed: '2026-01-31', focus: '2026-01-31' }) });
      const navigate = vi.fn();
      root.addEventListener('calendar:navigate', (event) => navigate(event.detail.to));

      key(day('2026-01-31'), 'PageDown');

      expect(navigate).toHaveBeenCalledWith('2026-02-28');
    });

    it('lets a cancelled before-navigate stop the request', async () => {
      const { root } = await render();
      root.addEventListener('calendar:before-navigate', (event) => event.preventDefault());
      const navigate = vi.fn();
      root.addEventListener('calendar:navigate', navigate);

      key(day('2026-09-15'), 'PageDown');

      expect(navigate).not.toHaveBeenCalled();
    });

    it('opens a year with Space instead of scrolling', async () => {
      await render({ grid: decadeMarkup('2026-01-01') });
      const open = vi.fn((event) => event.preventDefault());
      day('2026-01-01').addEventListener('click', open);

      expect(key(day('2026-01-01'), ' ').defaultPrevented).toBe(true);
      expect(open).toHaveBeenCalledOnce();
    });

    it('moves by rows of four in the decade view', async () => {
      await render({ grid: decadeMarkup('2026-01-01') });

      key(day('2026-01-01'), 'ArrowUp');
      expect(document.activeElement).toBe(day('2022-01-01'));

      key(day('2022-01-01'), 'End');
      expect(document.activeElement).toBe(day('2022-01-01'));

      key(day('2022-01-01'), 'Home');
      expect(document.activeElement).toBe(day('2019-01-01'));
    });
  });

  describe('selection', () => {
    it('commits a clicked day and reports the change', async () => {
      const { root } = await render({
        attrs: 'data-calendar-selectable-value="true" data-calendar-selected-value="2026-09-10"',
      });
      const change = vi.fn();
      root.addEventListener('calendar:changed', (event) => change(event.detail));

      day('2026-09-15').click();

      expect(change).toHaveBeenCalledWith({ value: '2026-09-15', previousValue: '2026-09-10' });
      expect(day('2026-09-15').closest('td').getAttribute('aria-selected')).toBe('true');
    });

    it('reports re-activating the current date so a dialog can close on it', async () => {
      const { root } = await render({
        attrs: 'data-calendar-selectable-value="true" data-calendar-selected-value="2026-09-15"',
      });
      const change = vi.fn();
      root.addEventListener('calendar:changed', (event) => change(event.detail));

      day('2026-09-15').click();

      expect(change).toHaveBeenCalledWith({ value: '2026-09-15', previousValue: '2026-09-15' });
    });

    it('keeps the user selection when the grid is replaced', async () => {
      const { root } = await render({
        attrs: 'data-calendar-selectable-value="true" data-calendar-selected-value="2026-09-10"',
      });
      day('2026-09-15').click();

      root.querySelector('table').outerHTML = monthMarkup({ focus: '2026-09-10', selected: '2026-09-10' });
      await vi.waitUntil(() => day('2026-09-15').closest('td').getAttribute('aria-selected') === 'true');

      expect(day('2026-09-10').closest('td').getAttribute('aria-selected')).toBe('false');
      expect(tabStops()).toEqual(['2026-09-15']);
    });

    it('lets a cancelled before-change keep the selection', async () => {
      const { root } = await render();
      root.addEventListener('calendar:before-change', (event) => event.preventDefault());

      day('2026-09-15').click();

      expect(day('2026-09-15').closest('td').getAttribute('aria-selected')).toBe('false');
    });

    it('refuses unavailable days and display-only calendars', async () => {
      const { controller } = await render({ grid: monthMarkup({ disabled: ['2026-09-16'] }) });
      expect(controller.select('2026-09-16')).toBe(false);

      const display = await render({ attrs: '' });
      expect(display.controller.select('2026-09-15')).toBe(false);
    });

    it('restores the server-rendered selection on form reset', async () => {
      await render({
        form: true,
        attrs: 'data-calendar-selectable-value="true" data-calendar-selected-value="2026-09-10"',
      });

      day('2026-09-15').click();
      document.querySelector('#form').reset();
      await flush();

      expect(day('2026-09-10').closest('td').getAttribute('aria-selected')).toBe('true');
      expect(day('2026-09-15').closest('td').getAttribute('aria-selected')).toBe('false');
    });
  });

  describe('navigation', () => {
    const link = (name, displayed, view = 'month') =>
      `<a href="?root%5Bdisplayed%5D=${displayed}&root%5Bview%5D=${view}" data-navigation="${name}">${name}</a>`;
    const frameContent = (displayed, heading, options = {}) => {
      const grid = (
        options.grid ?? monthMarkup({ displayed, focus: `${displayed.slice(0, 7)}-01`, ...options })
      ).replace('role="grid"', 'role="grid" aria-labelledby="root_heading"');
      return `<div>${link('previous', '2026-08-01')}<h2 id="root_heading">${heading}</h2>${link('next', '2026-10-01')}</div>${grid}`;
    };
    const renderFramed = async (attrs = 'data-calendar-selectable-value="true"') => {
      document.body.innerHTML = `<section id="root" data-controller="calendar calendar-turbo"
          data-calendar-navigation-value="turbo" ${attrs}
          data-action="click->calendar#onClick calendar:navigate->calendar-turbo#onNavigate
                       turbo:before-fetch-response->calendar-turbo#onResponse turbo:frame-missing->calendar-turbo#onError
                       turbo:fetch-request-error->calendar-turbo#onError calendar-turbo:failed->calendar#onFailed">
          <div role="status" data-calendar-target="status"></div>
          <turbo-frame id="root_frame">${frameContent('2026-09-15', 'September 2026')}</turbo-frame></section>`;
      const root = document.querySelector('#root');
      await vi.waitUntil(() => application.getControllerForElementAndIdentifier(root, 'calendar'));
      return { root, frame: document.querySelector('turbo-frame') };
    };
    const replace = async (frame, displayed, heading, options) => {
      frame.innerHTML = frameContent(displayed, heading, options);
      await flush();
    };

    it('loads the next period into the frame from the keyboard', async () => {
      const { frame } = await renderFramed();

      key(day('2026-09-15'), 'PageDown');

      const url = new URL(frame.src);
      expect(url.searchParams.get('root[displayed]')).toBe('2026-10-15');
      expect(url.searchParams.get('root[view]')).toBe('month');
    });

    it('builds the frame URL from the server-provided base', async () => {
      const { frame } = await renderFramed('data-calendar-url-value="/people/new?step=2"');

      key(day('2026-09-15'), 'PageDown');

      const url = new URL(frame.src);
      expect(url.pathname).toBe('/people/new');
      expect(url.searchParams.get('step')).toBe('2');
      expect(url.searchParams.get('root[displayed]')).toBe('2026-10-15');
    });

    it('focuses the intended date in the replacement and announces the period', async () => {
      const { root, frame } = await renderFramed();
      const navigated = vi.fn();
      root.addEventListener('calendar:navigated', (event) => navigated(event.detail));
      day('2026-09-15').focus();

      key(day('2026-09-15'), 'PageDown');
      await replace(frame, '2026-10-15', 'October 2026');

      expect(document.activeElement).toBe(day('2026-10-15'));
      expect(tabStops()).toEqual(['2026-10-15']);
      expect(root.querySelector('[role="status"]').textContent).toBe('October 2026');
      expect(navigated).toHaveBeenCalledWith({
        from: '2026-09-15',
        to: '2026-10-15',
        focusDate: '2026-10-15',
        view: 'month',
      });
    });

    it('arrives when the app displays another day of the requested month', async () => {
      const { frame } = await renderFramed();
      day('2026-09-15').focus();

      key(day('2026-09-15'), 'PageDown');
      await replace(frame, '2026-10-01', 'October 2026');

      expect(document.activeElement).toBe(day('2026-10-15'));
    });

    it('breaks a tie toward the direction of travel', async () => {
      const { frame } = await renderFramed();
      day('2026-09-15').focus();

      key(day('2026-09-15'), 'PageUp');
      await replace(frame, '2026-08-15', 'August 2026', { disabled: ['2026-08-15'] });

      expect(document.activeElement).toBe(day('2026-08-14'));
    });

    it('does not pull focus back after the user moved on', async () => {
      const { frame } = await renderFramed();
      document.body.insertAdjacentHTML('beforeend', '<button id="elsewhere">Elsewhere</button>');
      day('2026-09-15').focus();

      key(day('2026-09-15'), 'PageDown');
      document.querySelector('#elsewhere').focus();
      await replace(frame, '2026-10-15', 'October 2026');

      expect(document.activeElement).toBe(document.querySelector('#elsewhere'));
    });

    it('keeps the grid and reports a response without the frame', async () => {
      const { root, frame } = await renderFramed(`data-calendar-labels-value='{"error":"Could not load"}'`);
      day('2026-09-15').focus();
      key(day('2026-09-15'), 'PageDown');

      const missing = new CustomEvent('turbo:frame-missing', { bubbles: true, cancelable: true });
      frame.dispatchEvent(missing);

      expect(missing.defaultPrevented).toBe(true);
      expect(root.querySelector('[role="status"]').textContent).toBe('Could not load');
      expect(document.activeElement).toBe(day('2026-09-15'));
    });

    it('reports a failed response', async () => {
      const { root, frame } = await renderFramed(`data-calendar-labels-value='{"error":"Could not load"}'`);
      key(day('2026-09-15'), 'PageDown');

      frame.dispatchEvent(
        new CustomEvent('turbo:before-fetch-response', {
          bubbles: true,
          detail: { fetchResponse: { succeeded: false } },
        })
      );

      expect(root.querySelector('[role="status"]').textContent).toBe('Could not load');
    });

    it('moves to the nearest available date when the intended one is not', async () => {
      const { frame } = await renderFramed();
      day('2026-09-15').focus();

      key(day('2026-09-15'), 'PageDown');
      await replace(frame, '2026-10-15', 'October 2026', { disabled: ['2026-10-15'] });

      expect(document.activeElement).toBe(day('2026-10-16'));
    });

    it('ignores a stale response for another period', async () => {
      const { frame } = await renderFramed();
      day('2026-09-15').focus();
      key(day('2026-09-15'), 'PageDown');

      await replace(frame, '2026-11-15', 'November 2026');
      expect(document.activeElement).toBe(document.body);

      await replace(frame, '2026-10-15', 'October 2026');
      expect(document.activeElement).toBe(day('2026-10-15'));
    });

    it('loads a navigation link into the frame and returns focus to it', async () => {
      const { root, frame } = await renderFramed();
      const navigate = vi.fn();
      root.addEventListener('calendar:navigate', (event) => navigate(event.detail));
      const next = root.querySelector('[data-navigation="next"]');
      next.focus();

      const click = new MouseEvent('click', { bubbles: true, cancelable: true });
      next.dispatchEvent(click);
      expect(frame.src).toBe(next.href);
      await replace(frame, '2026-10-01', 'October 2026');

      expect(click.defaultPrevented).toBe(true);
      expect(navigate).toHaveBeenCalledWith({
        from: '2026-09-15',
        to: '2026-10-01',
        focusDate: null,
        view: 'month',
        url: next.href,
      });
      expect(document.activeElement).toBe(root.querySelector('[data-navigation="next"]'));
    });

    it('leaves focus alone when it was outside the calendar', async () => {
      const { root, frame } = await renderFramed();

      root
        .querySelector('[data-navigation="next"]')
        .dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable: true }));
      await replace(frame, '2026-10-01', 'October 2026');

      expect(document.activeElement).toBe(document.body);
    });

    it('lets a cancelled before-navigate stop a link', async () => {
      const { root } = await renderFramed();
      root.addEventListener('calendar:before-navigate', (event) => event.preventDefault());

      const click = new MouseEvent('click', { bubbles: true, cancelable: true });
      root.querySelector('[data-navigation="next"]').dispatchEvent(click);

      expect(click.defaultPrevented).toBe(true);
    });

    it('focuses the zoomed-in grid after opening a year', async () => {
      const { root, frame } = await renderFramed();
      await replace(frame, '2026-01-01', '2020 – 2029', { grid: decadeMarkup('2026-01-01') });
      const year = day('2024-01-01');
      year.href = '?root%5Bdisplayed%5D=2024-01-01&root%5Bview%5D=year';
      year.focus();

      year.dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable: true }));
      const months = Array.from({ length: 12 }, (_, index) => `2024-${String(index + 1).padStart(2, '0')}-01`);
      const yearGrid = `<table role="grid" data-calendar-target="grid" data-displayed="2024-01-01" data-view="year"
          data-action="keydown->calendar#onKeydown"><tbody><tr>${months
            .map(
              (month) => `<td role="gridcell"><a href="#" tabindex="${month === '2024-01-01' ? 0 : -1}"
               data-calendar-target="period" data-date="${month}">${month}</a></td>`
            )
            .join('')}</tr></tbody></table>`;
      await replace(frame, '2024-01-01', '2024', { grid: yearGrid });

      expect(root.contains(document.activeElement)).toBe(true);
      expect(document.activeElement.dataset.date).toBe('2024-01-01');
    });

    it('clears the announcement before Turbo caches the page', async () => {
      const { root, frame } = await renderFramed();
      day('2026-09-15').focus();
      key(day('2026-09-15'), 'PageDown');
      await replace(frame, '2026-10-15', 'October 2026');

      document.dispatchEvent(new Event('turbo:before-cache'));

      expect(root.querySelector('[role="status"]').textContent).toBe('');
    });
  });

  it('reports a min after max', async () => {
    await render({ attrs: 'data-calendar-min-value="2026-09-20" data-calendar-max-value="2026-09-01"' });

    expect(consoleError).toHaveBeenCalledWith(expect.stringContaining('min is after max'));
  });

  describe('stimulus mode', () => {
    const header = `<div>
        <button type="button" data-navigation="previous"></button><h2 id="root_heading"></h2>
        <button type="button" data-navigation="zoom"></button><button type="button" data-navigation="next"></button>
      </div>`;
    const renderLocal = async (attrs = '', templates = '') => {
      document.body.innerHTML = `<section id="root" data-controller="calendar" data-action="click->calendar#onClick"
          data-calendar-selectable-value="true" ${attrs}>
          <div role="status" data-calendar-target="status"></div>
          <div id="root_frame" hidden>${header}
            <table role="grid" aria-labelledby="root_heading" data-calendar-target="grid"
                   data-action="keydown->calendar#onKeydown"></table></div>${templates}</section>`;
      const root = document.querySelector('#root');
      await vi.waitUntil(() => root.querySelector('[data-date]'));
      return root;
    };
    const values =
      'data-calendar-displayed-value="2026-09-10" data-calendar-today-value="2026-09-10" ' +
      'data-calendar-selected-value="2026-09-15" data-calendar-locale-value="en-US" ' +
      'data-calendar-first-day-of-week-value="1"';

    it('draws the period from its values', async () => {
      const root = await renderLocal(`${values} data-calendar-min-value="2026-09-03"`);

      expect(root.querySelector('h2').textContent).toBe('September 2026');
      expect([...root.querySelectorAll('th')].map((th) => th.textContent)).toEqual([
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ]);
      expect(root.querySelector('th').abbr).toBe('Monday');
      expect(root.querySelectorAll('[data-calendar-target="day"]')).toHaveLength(30);
      expect(day('2026-09-15').getAttribute('aria-label')).toBe('September 15, 2026');
      expect(day('2026-09-15').closest('td').getAttribute('aria-selected')).toBe('true');
      expect(day('2026-09-15').tabIndex).toBe(0);
      expect(day('2026-09-10').getAttribute('aria-current')).toBe('date');
      expect(day('2026-09-02').getAttribute('aria-disabled')).toBe('true');
      expect(root.querySelector('[data-navigation="previous"]').getAttribute('aria-label')).toBe('Previous month');
      expect(root.querySelector('[data-navigation="zoom"]').textContent).toBe('Choose month');
    });

    it('shows the drawn calendar', async () => {
      const root = await renderLocal(values);

      expect(root.querySelector('#root_frame').hidden).toBe(false);
    });

    it('draws from the selection or today when the displayed value is not a date', async () => {
      const root = await renderLocal(
        'data-calendar-displayed-value="soon" data-calendar-selected-value="2026-03-04" data-calendar-locale-value="en-US"'
      );

      expect(root.querySelector('h2').textContent).toBe('March 2026');
    });

    it('moves focus to the grid when the next control hides at year 9999', async () => {
      const root = await renderLocal('data-calendar-displayed-value="9999-11-15" data-calendar-locale-value="en-US"');
      const next = root.querySelector('[data-navigation="next"]');
      next.focus();

      next.click();

      expect(next.hidden).toBe(true);
      expect(document.activeElement.dataset.date).toMatch(/^9999-12-/);
    });

    it('defaults to the browser locale, its week start, and today', async () => {
      const now = new Date();
      const today = [now.getFullYear(), now.getMonth() + 1, now.getDate()]
        .map((part, index) => String(part).padStart(index ? 2 : 4, '0'))
        .join('-');
      const root = await renderLocal();

      expect(root.querySelector('th').abbr).toBe('Sunday');
      expect(day(today).getAttribute('aria-current')).toBe('date');
      expect(day(today).tabIndex).toBe(0);
    });

    it('builds cells from the templates', async () => {
      const root = await renderLocal(
        values,
        `<template data-calendar-target="weekdayTemplate"><th class="weekday"></th></template>
         <template data-calendar-target="cellTemplate"><td class="cell"></td></template>
         <template data-calendar-target="dateTemplate"><td class="cell"><button type="button" class="date"></button></td></template>`
      );

      expect(root.querySelector('th').className).toBe('weekday');
      expect(day('2026-09-15').className).toBe('date');
      expect(day('2026-09-15').closest('td').className).toBe('cell');
    });

    it('takes its labels from the labels value', async () => {
      const root = await renderLocal(`${values} data-calendar-labels-value='{"previousMonth":"Mois précédent"}'`);

      expect(root.querySelector('[data-navigation="previous"]').getAttribute('aria-label')).toBe('Mois précédent');
      expect(root.querySelector('[data-navigation="next"]').getAttribute('aria-label')).toBe('Next month');
    });

    it('draws the next month from the next button and keeps focus on it', async () => {
      const root = await renderLocal(values);
      const navigate = vi.fn();
      root.addEventListener('calendar:navigate', (event) => navigate(event.detail));
      const next = root.querySelector('[data-navigation="next"]');
      next.focus();

      next.click();

      expect(root.querySelector('h2').textContent).toBe('October 2026');
      expect(root.querySelector('[role="status"]').textContent).toBe('October 2026');
      expect(document.activeElement).toBe(next);
      expect(navigate).toHaveBeenCalledWith(expect.objectContaining({ to: '2026-10-01', view: 'month' }));
    });

    it('draws the intended date when the keyboard leaves the period', async () => {
      await renderLocal(values);
      day('2026-09-15').focus();

      key(day('2026-09-15'), 'PageDown');

      expect(document.activeElement).toBe(day('2026-10-15'));
    });

    it('zooms out to the year and back into a month', async () => {
      const root = await renderLocal(values);
      root.querySelector('[data-navigation="zoom"]').click();

      expect(root.querySelector('h2').textContent).toBe('2026');
      expect(root.querySelector('[data-navigation="zoom"]').textContent).toBe('Choose year');
      expect(day('2026-09-01').getAttribute('aria-label')).toBe('September 2026');

      day('2026-03-01').click();

      expect(root.querySelector('h2').textContent).toBe('March 2026');
    });

    it('shows the decade and hides the zoom at the top', async () => {
      const root = await renderLocal(`${values} data-calendar-view-value="decade"`);

      expect(root.querySelector('h2').textContent).toMatch(/^2020\s–\s2029$/);
      expect(root.querySelector('[data-navigation="zoom"]').hidden).toBe(true);
      expect(day('2019-01-01').dataset.outside).toBe('true');
    });

    it('hides the step past year 0001', async () => {
      const root = await renderLocal('data-calendar-displayed-value="0001-01-15" data-calendar-locale-value="en-US"');

      expect(root.querySelector('[data-navigation="previous"]').hidden).toBe(true);
      expect(root.querySelector('[data-navigation="next"]').hidden).toBe(false);
    });
  });
});
