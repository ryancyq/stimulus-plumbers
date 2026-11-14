import {
  addMonths,
  addYears,
  dateKey,
  isDisabled,
  isMonthDisabled,
  isYearDisabled,
  monthGrid,
  parseDateKey,
} from '../../date';

const COLUMNS = 4;
const LEVELS = ['month', 'year', 'decade'];

// A UTC instant for Intl only; never used for arithmetic.
const instant = ({ year, month, day }) => {
  const date = new Date(Date.UTC(2000, month - 1, day));
  date.setUTCFullYear(year);
  return date;
};

// Builds the instant from the key's parts; keys may have year 0.
const instantOf = (key) =>
  instant({ year: Number(key.slice(0, 4)), month: Number(key.slice(5, 7)), day: Number(key.slice(8, 10)) });

const formatter = (locale, options) => {
  try {
    return new Intl.DateTimeFormat(locale || undefined, { ...options, timeZone: 'UTC' });
  } catch {
    return new Intl.DateTimeFormat(undefined, { ...options, timeZone: 'UTC' });
  }
};

const inRange = (key) => {
  const year = Number(key.slice(0, 4));
  return year >= 1 && year <= 9999;
};

// The locale's first day of the week, 0 for Sunday; Monday when the browser cannot tell.
export function weekStart(locale) {
  try {
    const info = new Intl.Locale(locale || new Intl.DateTimeFormat().resolvedOptions().locale);
    const firstDay = (info.getWeekInfo?.() ?? info.weekInfo)?.firstDay;
    return firstDay ? firstDay % 7 : 1;
  } catch {
    return 1;
  }
}

export function todayKey() {
  const now = new Date();
  return dateKey({ year: now.getFullYear(), month: now.getMonth() + 1, day: now.getDate() });
}

export function levelName(level) {
  return LEVELS.includes(level) ? level : 'month';
}

// A date key as the level's cell key: itself, its month, or its year.
export function unitKey(key, level) {
  if (!key) return null;
  if (level === 'year') return `${key.slice(0, 7)}-01`;
  return level === 'decade' ? `${key.slice(0, 4)}-01-01` : key;
}

// The same month a year away, or null outside 0001–9999.
export function neighbourYear(displayed, direction) {
  const date = parseDateKey(displayed);
  if (!date) return null;

  const target = addYears({ ...date, day: 1 }, direction);
  return target ? dateKey(target) : null;
}

// The period one step away, or null outside 0001–9999.
export function neighbour(displayed, level, direction) {
  const date = parseDateKey(displayed);
  if (!date) return null;

  const first = { ...date, day: 1 };
  const target =
    level === 'month'
      ? addMonths(first, direction)
      : addYears({ ...first, month: 1 }, level === 'year' ? direction : direction * 10);
  return target ? dateKey(target) : null;
}

export function zoomOut(level) {
  return { month: 'year', year: 'decade' }[level] ?? null;
}

export function zoomIn(level) {
  return { year: 'month', decade: 'year' }[level] ?? null;
}

const grids = {
  month({ displayed, firstDayOfWeek, showOtherMonths, availability, locale }) {
    const date = parseDateKey(displayed);
    const month = displayed.slice(0, 7);
    const dayFormat = formatter(locale, { day: 'numeric' });
    const labelFormat = formatter(locale, { dateStyle: 'long' });
    return {
      heading: formatter(locale, { month: 'long', year: 'numeric' }).format(instant(date)),
      rows: monthGrid(date, firstDayOfWeek),
      target: 'day',
      navigable: (key) => inRange(key) && (showOtherMonths || key.startsWith(month)),
      outside: (key) => !key.startsWith(month),
      disabled: (key) => isDisabled(parseDateKey(key), availability),
      text: (key) => dayFormat.format(instantOf(key)),
      label: (key) => labelFormat.format(instantOf(key)),
    };
  },

  year({ displayed, availability, locale }) {
    const year = Number(displayed.slice(0, 4));
    const keys = Array.from({ length: 12 }, (_, index) => dateKey({ year, month: index + 1, day: 1 }));
    const monthFormat = formatter(locale, { month: 'long' });
    const labelFormat = formatter(locale, { month: 'long', year: 'numeric' });
    return {
      heading: formatter(locale, { year: 'numeric' }).format(instant({ year, month: 1, day: 1 })),
      rows: rowsOf(keys),
      target: 'period',
      navigable: inRange,
      outside: () => false,
      disabled: (key) => isMonthDisabled(year, Number(key.slice(5, 7)), availability),
      text: (key) => monthFormat.format(instantOf(key)),
      label: (key) => labelFormat.format(instantOf(key)),
    };
  },

  decade({ displayed, availability, locale }) {
    const year = Number(displayed.slice(0, 4));
    const first = year - (year % 10);
    const years = Array.from({ length: 12 }, (_, index) => first - 1 + index);
    const keys = years.map((value) =>
      value >= 1 && value <= 9999 ? dateKey({ year: value, month: 1, day: 1 }) : null
    );
    const yearFormat = formatter(locale, { year: 'numeric' });
    return {
      heading: yearFormat.formatRange(
        instant({ year: first, month: 1, day: 1 }),
        instant({ year: first + 9, month: 1, day: 1 })
      ),
      rows: rowsOf(keys),
      target: 'period',
      navigable: (key) => key != null,
      outside: (key) => Number(key.slice(0, 4)) < first || Number(key.slice(0, 4)) > first + 9,
      disabled: (key) => isYearDisabled(Number(key.slice(0, 4)), availability),
      text: (key) => yearFormat.format(instantOf(key)),
      label: () => null,
    };
  },
};

function rowsOf(keys) {
  return Array.from({ length: Math.ceil(keys.length / COLUMNS) }, (_, row) =>
    keys.slice(row * COLUMNS, (row + 1) * COLUMNS)
  );
}

function clone(template, tag) {
  return template?.content.firstElementChild?.cloneNode(true) ?? document.createElement(tag);
}

function control(templates) {
  const cell = clone(templates.date, 'td');
  if (!cell.querySelector('button')) {
    const button = document.createElement('button');
    button.type = 'button';
    cell.append(button);
  }
  return cell;
}

// Selected, then today, then the displayed date, then the first enabled cell.
function focusKey(period, keys, { selected, today, displayed }, level) {
  const enabled = keys.filter((key) => key && period.navigable(key) && !period.disabled(key));
  return (
    [selected, today, displayed].map((key) => unitKey(key, level)).find((key) => enabled.includes(key)) ?? enabled[0]
  );
}

// Fills a grid with one period; returns the heading text.
export function renderPeriod(grid, options) {
  const level = levelName(options.level);
  const period = grids[level](options);
  const templates = options.templates ?? {};
  const focus = focusKey(period, period.rows.flat(), options, level);
  const today = unitKey(options.today, level);

  const head = [];
  if (level === 'month') {
    const long = formatter(options.locale, { weekday: 'long' });
    const short = formatter(options.locale, { weekday: 'short' });
    const row = document.createElement('tr');
    period.rows[0].forEach((key) => {
      const header = clone(templates.weekday, 'th');
      header.scope = 'col';
      header.abbr = long.format(instantOf(key));
      header.textContent = short.format(instantOf(key));
      row.append(header);
    });
    const thead = document.createElement('thead');
    thead.append(row);
    head.push(thead);
  }

  const body = document.createElement('tbody');
  period.rows.forEach((keys) => {
    const row = document.createElement('tr');
    keys.forEach((key) => {
      if (!key || !period.navigable(key)) {
        row.append(clone(templates.cell, 'td'));
        return;
      }

      const cell = control(templates);
      const button = cell.querySelector('button');
      cell.setAttribute('role', 'gridcell');
      if (level === 'month' && options.selectable) cell.setAttribute('aria-selected', String(key === options.selected));
      button.tabIndex = key === focus ? 0 : -1;
      button.textContent = period.text(key);
      const label = period.label(key);
      if (label) button.setAttribute('aria-label', label);
      if (key === today) button.setAttribute('aria-current', 'date');
      if (period.disabled(key)) button.setAttribute('aria-disabled', 'true');
      button.dataset.calendarTarget = period.target;
      button.dataset.date = key;
      if (period.outside(key)) button.dataset.outside = 'true';
      row.append(cell);
    });
    body.append(row);
  });

  grid.dataset.displayed = options.displayed;
  grid.dataset.level = level;
  if (level === 'month' && !options.selectable) grid.setAttribute('aria-readonly', 'true');
  else grid.removeAttribute('aria-readonly');
  grid.replaceChildren(...head, body);
  return period.heading;
}
