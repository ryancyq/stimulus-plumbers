// Civil dates as { year, month, day } with month 1–12; never a Date or an instant.
// Date keys (YYYY-MM-DD) at the boundaries, parts for arithmetic; years 0001–9999.
const KEY_PATTERN = /^(\d{4})-(\d{2})-(\d{2})$/;
const inRange = (date) => (date.year >= 1 && date.year <= 9999 ? date : null);

export function daysInMonth(year, month) {
  if (month === 2) return year % 4 === 0 && (year % 100 !== 0 || year % 400 === 0) ? 29 : 28;
  return [4, 6, 9, 11].includes(month) ? 30 : 31;
}

export function parseDateKey(value) {
  const match = KEY_PATTERN.exec(value ?? '');
  if (!match) return null;

  const [year, month, day] = match.slice(1).map(Number);
  if (year < 1 || month < 1 || month > 12 || day < 1 || day > daysInMonth(year, month)) return null;
  return { year, month, day };
}

export function dateKey({ year, month, day }) {
  return `${String(year).padStart(4, '0')}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
}

export function compareDate(a, b) {
  return a.year - b.year || a.month - b.month || a.day - b.day;
}

// Days since 1970-01-01 (proleptic Gregorian).
function toDayNumber({ year, month, day }) {
  const y = month <= 2 ? year - 1 : year;
  const era = Math.floor(y / 400);
  const yearOfEra = y - era * 400;
  const dayOfYear = Math.floor((153 * ((month + 9) % 12) + 2) / 5) + day - 1;
  const dayOfEra = yearOfEra * 365 + Math.floor(yearOfEra / 4) - Math.floor(yearOfEra / 100) + dayOfYear;
  return era * 146097 + dayOfEra - 719468;
}

function fromDayNumber(number) {
  const z = number + 719468;
  const era = Math.floor(z / 146097);
  const dayOfEra = z - era * 146097;
  const yearOfEra = Math.floor(
    (dayOfEra - Math.floor(dayOfEra / 1460) + Math.floor(dayOfEra / 36524) - Math.floor(dayOfEra / 146096)) / 365
  );
  const dayOfYear = dayOfEra - (365 * yearOfEra + Math.floor(yearOfEra / 4) - Math.floor(yearOfEra / 100));
  const shifted = Math.floor((5 * dayOfYear + 2) / 153);
  const month = shifted < 10 ? shifted + 3 : shifted - 9;
  return {
    year: yearOfEra + era * 400 + (month <= 2 ? 1 : 0),
    month,
    day: dayOfYear - Math.floor((153 * shifted + 2) / 5) + 1,
  };
}

export function daysBetween(from, to) {
  return toDayNumber(to) - toDayNumber(from);
}

export function addDays(date, amount) {
  return inRange(fromDayNumber(toDayNumber(date) + amount));
}

// `clamp` moves an overflowing day to the month's last day; `reject` returns null.
export function addMonths(date, amount, overflow = 'clamp') {
  const index = date.year * 12 + (date.month - 1) + amount;
  const year = Math.floor(index / 12);
  const month = index - year * 12 + 1;
  const last = daysInMonth(year, month);
  if (date.day > last && overflow === 'reject') return null;
  return inRange({ year, month, day: Math.min(date.day, last) });
}

export function addYears(date, amount, overflow = 'clamp') {
  return addMonths(date, amount * 12, overflow);
}

// 0 is Sunday.
export function weekday(date) {
  return (((toDayNumber(date) + 4) % 7) + 7) % 7;
}

// Whole weeks covering the month, as date keys.
export function monthGrid(date, firstDayOfWeek = 0) {
  const first = { year: date.year, month: date.month, day: 1 };
  const last = { ...first, day: daysInMonth(date.year, date.month) };
  const start = toDayNumber(first) - ((weekday(first) - firstDayOfWeek + 7) % 7);
  const end = toDayNumber(last) + ((firstDayOfWeek + 6 - weekday(last)) % 7);
  const weeks = [];
  for (let number = start; number <= end; number += 7) {
    weeks.push(Array.from({ length: 7 }, (_, offset) => dateKey(fromDayNumber(number + offset))));
  }
  return weeks;
}

// Availability uses date keys for `min`, `max`, and `disabledDates`; integers for the rest.
export function isDisabled(date, availability = {}) {
  const { min, max, disabledDates = [], disabledWeekdays = [], disabledMonths = [], disabledYears = [] } = availability;
  const key = dateKey(date);
  return (
    (min != null && key < min) ||
    (max != null && key > max) ||
    disabledDates.includes(key) ||
    disabledWeekdays.includes(weekday(date)) ||
    disabledMonths.includes(date.month) ||
    disabledYears.includes(date.year)
  );
}

// A month is unavailable when listed, when its year is, or when it lies outside min–max.
export function isMonthDisabled(year, month, availability = {}) {
  const { min, max, disabledMonths = [] } = availability;
  const first = dateKey({ year, month, day: 1 });
  const last = dateKey({ year, month, day: daysInMonth(year, month) });
  return (
    disabledMonths.includes(month) ||
    isYearDisabled(year, availability) ||
    (min != null && last < min) ||
    (max != null && first > max)
  );
}

// A year is unavailable when listed or when it lies outside min–max.
export function isYearDisabled(year, availability = {}) {
  const { min, max, disabledYears = [] } = availability;
  return (
    disabledYears.includes(year) ||
    (min != null && year < Number(min.slice(0, 4))) ||
    (max != null && year > Number(max.slice(0, 4)))
  );
}

// Problems that make availability unusable, each starting with the option it names; empty when valid.
export function availabilityErrors(availability = {}) {
  const { min, max, disabledDates = [], disabledWeekdays = [], disabledMonths = [], disabledYears = [] } = availability;
  const integers = (values, low, high) =>
    values.every((value) => Number.isInteger(value) && value >= low && value <= high);
  const errors = [];
  if (min != null && !parseDateKey(min)) errors.push('min must be a date key');
  if (max != null && !parseDateKey(max)) errors.push('max must be a date key');
  if (parseDateKey(min) && parseDateKey(max) && min > max) errors.push('min is after max');
  if (!disabledDates.every(parseDateKey)) errors.push('disabledDates must be date keys');
  if (!integers(disabledWeekdays, 0, 6)) errors.push('disabledWeekdays must be integers 0–6');
  if (!integers(disabledMonths, 1, 12)) errors.push('disabledMonths must be integers 1–12');
  if (!integers(disabledYears, 1, 9999)) errors.push('disabledYears must be integers 1–9999');
  return errors;
}

// Date keys in and out; `dates` are the navigable dates. Selected, then today, then the displayed
// date, then the first enabled date.
export function focusDate({ dates, selected, today, displayed, availability }) {
  const enabled = dates.filter((key) => !isDisabled(parseDateKey(key), availability));
  return [selected, today, displayed].find((key) => key && enabled.includes(key)) ?? enabled[0] ?? null;
}
