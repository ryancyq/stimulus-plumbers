import { Controller } from '@hotwired/stimulus';
import { isAriaDisabled, setSelected } from '../accessibility/aria';
import {
  addDays,
  addMonths,
  addYears,
  availabilityErrors,
  dateKey,
  daysBetween,
  focusDate,
  parseDateKey,
} from '../date';
import {
  neighbour,
  neighbourYear,
  renderPeriod,
  todayKey,
  unitKey,
  viewName,
  weekStart,
  zoomIn,
  zoomOut,
} from '../plumbers/plumber/calendar_period';

const CONTROL_SELECTOR = '[data-calendar-target~="day"], [data-calendar-target~="period"]';
const PERIOD_COLUMNS = 4;
const LABELS = {
  previousMonth: 'Previous month',
  nextMonth: 'Next month',
  previousYear: 'Previous year',
  nextYear: 'Next year',
  previousDecade: 'Previous decade',
  nextDecade: 'Next decade',
  chooseMonth: 'Choose month',
  chooseYear: 'Choose year',
  error: 'The calendar could not be loaded',
};

export default class extends Controller {
  static targets = ['status', 'grid', 'day', 'period', 'weekdayTemplate', 'cellTemplate', 'dateTemplate'];
  static values = {
    selected: String,
    selectable: Boolean,
    navigation: { type: String, default: 'stimulus' },
    displayed: String,
    view: { type: String, default: 'month' },
    today: String,
    locale: String,
    firstDayOfWeek: Number,
    showOtherMonths: Boolean,
    labels: Object,
    min: String,
    max: String,
    disabledDates: Array,
    disabledWeekdays: Array,
    disabledMonths: Array,
    disabledYears: Array,
  };

  connect() {
    this.connection = new AbortController();
    // Survives reconnects.
    this.initial ??= this.selectedValue;
    this.element
      .closest('form')
      ?.addEventListener(
        'reset',
        (event) => setTimeout(() => event.defaultPrevented || !this.connection || this._restore()),
        { signal: this.connection.signal }
      );

    document.addEventListener('turbo:before-cache', () => this._clearNavigation(), { signal: this.connection.signal });

    const errors = availabilityErrors(this._availability());
    if (errors.length) console.error(`CalendarController has invalid availability: ${errors.join('; ')}.`);
  }

  disconnect() {
    this.connection?.abort();
    this.connection = null;
  }

  // Draws an empty grid in stimulus mode.
  gridTargetConnected(grid) {
    if (this._usesStimulusNavigation && !grid.querySelector('[data-date]')) {
      const displayed = [this.displayedValue, this.selectedValue, this._today].find((key) => parseDateKey(key));
      this._draw(grid, displayed ?? todayKey(), viewName(this.viewValue));
    }
    this._syncGrid(grid);
  }

  _syncGrid(grid) {
    this._syncSelected();
    this._normalize(grid);
    if (this.pending && this._showsPeriod(grid, this.pending)) this._finishNavigation(grid);
    else this._focusSelected();
  }

  onKeydown(event) {
    if (event.altKey || event.ctrlKey || event.metaKey) return;

    const control = event.target.closest?.(CONTROL_SELECTOR);
    if (!control || !this.hasGridTarget || !this.gridTarget.contains(control)) return;

    if (event.key === ' ' && control.matches('[data-calendar-target~="period"]')) {
      event.preventDefault();
      control.click();
      return;
    }
    // The first or last cell shown in the row.
    if (event.key === 'Home' || event.key === 'End') {
      const row = [...control.closest('tr').querySelectorAll(CONTROL_SELECTOR)];
      event.preventDefault();
      this._moveTo((event.key === 'Home' ? row[0] : row.at(-1)).dataset.date, control);
      return;
    }

    const target = this._step(parseDateKey(control.dataset.date), event);
    if (!target) return;
    event.preventDefault();
    this._moveTo(dateKey(target), control);
  }

  onClick(event) {
    const day = event.target.closest?.('[data-calendar-target~="day"]');
    if (day) {
      this.select(day.dataset.date);
      return;
    }

    const link = event.target.closest?.('a[href]');
    if (link && this.element.contains(link)) {
      this._followPeriodLink(link, event);
      return;
    }

    if (this._usesStimulusNavigation) this._pressNavigation(event.target.closest?.('button'));
  }

  onFailed() {
    if (this.pending) this._navigationFailed();
  }

  // Focuses the grid's Tab stop, or with none the first shown, enabled header control.
  focusTabStop() {
    (this.gridTarget.querySelector('[tabindex="0"]') ?? this._usableControl())?.focus();
  }

  // Selects an enabled, rendered date, including the current one; returns false when refused.
  select(value) {
    const day = this._control(value);
    if (!this.selectableValue || !day || isAriaDisabled(day)) return false;

    const detail = { value, previousValue: this.selectedValue };
    if (this.dispatch('before-change', { detail, cancelable: true }).defaultPrevented) return false;

    this.selectedValue = value;
    this._syncSelected();
    this.dispatch('changed', { detail });
    return true;
  }

  // The date an arrow or page key moves to, or null for other keys.
  _step(date, event) {
    const view = this.gridTarget.dataset.view;
    if (view === 'month') return this._stepDay(date, event);

    const add = view === 'year' ? addMonths : addYears;
    const moves = { ArrowLeft: -1, ArrowRight: 1, ArrowUp: -PERIOD_COLUMNS, ArrowDown: PERIOD_COLUMNS };
    return event.key in moves ? add(date, moves[event.key]) : null;
  }

  _stepDay(date, event) {
    const page = event.shiftKey ? addYears : addMonths;
    switch (event.key) {
      case 'ArrowLeft':
        return addDays(date, -1);
      case 'ArrowRight':
        return addDays(date, 1);
      case 'ArrowUp':
        return addDays(date, -7);
      case 'ArrowDown':
        return addDays(date, 7);
      case 'PageUp':
        return page(date, -1);
      case 'PageDown':
        return page(date, 1);
      default:
        return null;
    }
  }

  _moveTo(key, from) {
    const control = this._control(key);
    if (!control) {
      this._navigate(key, key > from.dataset.date ? 1 : -1);
      return;
    }

    from.tabIndex = -1;
    control.tabIndex = 0;
    control.focus();
  }

  _navigate(key, direction) {
    const view = this.gridTarget.dataset.view;
    const url = this._usesStimulusNavigation ? null : this._periodLink(key, view)?.href;
    if (this._usesStimulusNavigation || url)
      this._request({ to: key, focusDate: key, view, url }, { focus: 'grid', direction });
  }

  // The header link to a period, which holds its URL in turbo mode.
  _periodLink(key, view) {
    const links = this.element.querySelectorAll('a[data-navigation]');
    return [...links].find(
      (link) => link.dataset.view === view && this._period(link.dataset.date ?? '', view) === this._period(key, view)
    );
  }

  // Period links in turbo mode.
  _followPeriodLink(link, event) {
    const { date: to, view } = link.dataset;
    if (!to || !view || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;

    event.preventDefault();
    const focus = link.dataset.navigation
      ? { focus: 'navigation', navigation: link.dataset.navigation }
      : { focus: 'grid' };
    this._request({ to, focusDate: null, view, url: link.href }, focus);
  }

  // Header buttons and period cells in stimulus mode.
  _pressNavigation(button) {
    if (!button || !this.element.contains(button) || isAriaDisabled(button)) return;

    const { displayed, view } = this.gridTarget.dataset;
    const name = button.dataset.navigation;
    if (name) {
      const [to, target] = this._navigationTarget(name, displayed, view);
      if (to && target) this._request({ to, focusDate: null, view: target }, { focus: 'navigation', navigation: name });
    } else if (button.matches('[data-calendar-target~="period"]')) {
      this._request({ to: button.dataset.date, focusDate: null, view: zoomIn(view) }, { focus: 'grid' });
    }
  }

  _navigationTarget(name, displayed, view) {
    if (name === 'zoom') return [displayed, zoomOut(view)];

    const direction = name.startsWith('next') ? 1 : -1;
    return [name.endsWith('year') ? neighbourYear(displayed, direction) : neighbour(displayed, view, direction), view];
  }

  // Stimulus navigation draws the period; turbo navigation loads `url`.
  _request({ to, focusDate: intended, view, url }, focus) {
    const detail = {
      from: this.gridTarget.dataset.displayed,
      to,
      focusDate: intended,
      view,
      ...(url && { url }),
    };
    if (this.dispatch('before-navigate', { detail, cancelable: true }).defaultPrevented) return false;

    this.pending = { ...detail, ...focus, restore: this.element.contains(document.activeElement) };
    this.dispatch('navigate', { detail });
    if (this._usesStimulusNavigation) {
      this._draw(this.gridTarget, to, view);
      this._syncGrid(this.gridTarget);
    }
    return true;
  }

  // Whether a replacement shows the requested period.
  _showsPeriod(grid, { to, view }) {
    return grid.dataset.view === view && this._period(grid.dataset.displayed, view) === this._period(to, view);
  }

  _period(key, view) {
    if (view === 'month') return key.slice(0, 7);
    return view === 'year' ? key.slice(0, 4) : key.slice(0, 3);
  }

  // Restores focus intent, announces the period, and dispatches navigated.
  _finishNavigation(grid) {
    const { from, to, focusDate: intended, view, focus, navigation, direction } = this.pending;
    // Focus is still here, or fell to the body with the replaced control.
    const restore = this.pending.restore && (this.element.contains(document.activeElement) || this._isFocusOnBody());
    this.pending = null;

    if (!intended) this._focusSelected();
    const target = intended
      ? this._nearestEnabled(grid, intended, view, direction)
      : grid.querySelector('[tabindex="0"]');
    if (target) this._takeTabStop(grid, target);
    if (restore && focus === 'grid') (target ?? this._fallbackControl(direction))?.focus();
    if (restore && focus === 'navigation') {
      // A hidden or missing control hands focus to the grid, or with no available date to another header control.
      const control = this.element.querySelector(`[data-navigation="${navigation}"]:not([hidden])`);
      (control ?? target ?? this._fallbackControl(direction))?.focus();
    }

    const heading = document.getElementById(grid.getAttribute('aria-labelledby'));
    if (this.hasStatusTarget && heading) this.statusTarget.textContent = heading.textContent;
    this.dispatch('navigated', { detail: { from, to, focusDate: target?.dataset.date ?? null, view } });
  }

  // The closest available date in the requested period; ties follow the direction of travel.
  _nearestEnabled(grid, key, view, direction) {
    const intended = parseDateKey(key);
    const distance = (control) => daysBetween(intended, parseDateKey(control.dataset.date));
    const candidates = [...grid.querySelectorAll(CONTROL_SELECTOR)].filter(
      (control) => !isAriaDisabled(control) && this._period(control.dataset.date, view) === this._period(key, view)
    );
    return candidates.reduce((best, control) => {
      if (!best) return control;
      const [near, current] = [Math.abs(distance(control)), Math.abs(distance(best))];
      if (near !== current) return near < current ? control : best;
      return Math.sign(distance(control)) === direction ? control : best;
    }, null);
  }

  // The header control for a period with no available date: previous or next in the direction of travel, zoom
  // after zooming in, or else the first shown, enabled control.
  _fallbackControl(direction) {
    const name = direction ? (direction < 0 ? 'previous' : 'next') : 'zoom';
    return this._usableControl(name) ?? this._usableControl();
  }

  // A shown, enabled header control: the named one, or else the first.
  _usableControl(name) {
    const control = name ? `[data-navigation="${name}"]` : '[data-navigation]';
    return this.element.querySelector(`${control}:not([hidden]):not([aria-disabled="true"])`);
  }

  _isFocusOnBody() {
    return document.activeElement === document.body || document.activeElement === document.documentElement;
  }

  _navigationFailed() {
    this.pending = null;
    if (this.hasStatusTarget) this.statusTarget.textContent = this._labels.error;
  }

  _draw(grid, displayed, view) {
    const heading = renderPeriod(grid, {
      displayed,
      view,
      today: this._today,
      selected: this.selectedValue || null,
      selectable: this.selectableValue,
      showOtherMonths: this.showOtherMonthsValue,
      firstDayOfWeek: this.hasFirstDayOfWeekValue ? this.firstDayOfWeekValue : weekStart(this.localeValue),
      availability: this._availability(),
      locale: this.localeValue,
      templates: {
        weekday: this.hasWeekdayTemplateTarget ? this.weekdayTemplateTarget : null,
        cell: this.hasCellTemplateTarget ? this.cellTemplateTarget : null,
        date: this.hasDateTemplateTarget ? this.dateTemplateTarget : null,
      },
    });
    const title = document.getElementById(grid.getAttribute('aria-labelledby'));
    if (title) title.textContent = heading;
    this._drawHeader(displayed, view);
    const shell = grid.closest('[hidden]');
    if (shell && this.element.contains(shell)) shell.hidden = false;
  }

  _drawHeader(displayed, view) {
    const noun = view[0].toUpperCase() + view.slice(1);
    ['previous', 'next'].forEach((name) => {
      const button = this.element.querySelector(`button[data-navigation="${name}"]`);
      if (!button) return;
      button.setAttribute('aria-label', this._labels[`${name}${noun}`]);
      button.hidden = !neighbour(displayed, view, name === 'next' ? 1 : -1);

      const year = this.element.querySelector(`button[data-navigation="${name}-year"]`);
      if (!year) return;
      year.setAttribute('aria-label', this._labels[`${name}Year`]);
      year.hidden = view !== 'month' || !neighbourYear(displayed, name === 'next' ? 1 : -1);
    });

    const zoom = this.element.querySelector('button[data-navigation="zoom"]');
    if (!zoom) return;
    const target = zoomOut(view);
    zoom.hidden = !target;
    zoom.textContent = target ? this._labels[target === 'year' ? 'chooseMonth' : 'chooseYear'] : '';
  }

  get _usesStimulusNavigation() {
    return this.navigationValue !== 'turbo';
  }

  get _today() {
    return this.todayValue || todayKey();
  }

  get _labels() {
    return { ...LABELS, ...this.labelsValue };
  }

  _takeTabStop(grid, control) {
    grid.querySelectorAll('[tabindex="0"]').forEach((other) => (other.tabIndex = -1));
    control.tabIndex = 0;
  }

  _clearNavigation() {
    this.pending = null;
    if (this.hasStatusTarget) this.statusTarget.textContent = '';
  }

  // Repairs markup without exactly one Tab stop; a grid with no available control needs none.
  _normalize(grid) {
    const controls = [...grid.querySelectorAll(CONTROL_SELECTOR)];
    if (controls.some((control) => !parseDateKey(control.dataset.date))) {
      console.error('CalendarController requires data-date="YYYY-MM-DD" on every day and period.');
    }

    const stops = controls.filter((control) => control.getAttribute('tabindex') === '0');
    const enabled = controls.filter((control) => !isAriaDisabled(control));
    if (stops.length === 1 || (!stops.length && !enabled.length)) return;

    console.warn(`CalendarController expected one cell with tabindex="0"; found ${stops.length}.`);
    const focus = focusDate({
      dates: enabled.map((control) => control.dataset.date),
      selected: unitKey(this.selectedValue, grid.dataset.view),
      today: grid.querySelector('[aria-current="date"]')?.dataset.date ?? null,
      displayed: unitKey(grid.dataset.displayed, grid.dataset.view),
    });
    controls.forEach((control) => (control.tabIndex = control.dataset.date === focus ? 0 : -1));
  }

  // Moves the Tab stop to the selected day when it is shown and available.
  _focusSelected() {
    const day = this.selectedValue && this.dayTargets.find((target) => target.dataset.date === this.selectedValue);
    if (day && !isAriaDisabled(day)) this._takeTabStop(this.gridTarget, day);
  }

  _syncSelected() {
    this.dayTargets.forEach((day) => {
      const cell = day.closest('[role="gridcell"]');
      if (cell?.hasAttribute('aria-selected')) setSelected(cell, day.dataset.date === this.selectedValue);
    });
  }

  _restore() {
    this.selectedValue = this.initial;
    this._syncSelected();
  }

  _control(key) {
    return this.hasGridTarget ? this.gridTarget.querySelector(`[data-date="${key}"]`) : null;
  }

  _availability() {
    return {
      min: this.minValue || null,
      max: this.maxValue || null,
      disabledDates: this.disabledDatesValue,
      disabledWeekdays: this.disabledWeekdaysValue,
      disabledMonths: this.disabledMonthsValue,
      disabledYears: this.disabledYearsValue,
    };
  }
}
