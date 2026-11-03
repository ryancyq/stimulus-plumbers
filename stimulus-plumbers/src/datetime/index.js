import { availabilityErrors as dateErrors, dateKey, daysBetween, parseDateKey } from '../date';
import { availabilityErrors as timeErrors, isEmpty, parseTimeKey, timeKey, trimRanges, windowRanges } from '../time';

// Date-times as { date, time } on the wall clock; never a Date or an instant.
// Date-time keys (YYYY-MM-DDTHH:MM) at the boundaries.
// Availability uses date-time keys for `min` and `max`, the date core's `disabled*`, and `time`, the time
// core's availability on every day.
const KEY_PATTERN = /^(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2})$/;

export function parseDateTimeKey(value) {
  const match = KEY_PATTERN.exec(value ?? '');
  const date = match && parseDateKey(match[1]);
  const time = match && parseTimeKey(match[2]);
  return date && time ? { date, time } : null;
}

export function dateTimeKey({ date, time }) {
  return `${dateKey(date)}T${timeKey(time)}`;
}

// The time core's availability on a date: the daily window's ranges, trimmed at `min` and `max` on their own dates.
export function dayAvailability(date, availability = {}) {
  const { min, max, time = {} } = availability;
  const prefix = `${dateKey(date)}T`;
  const from = min?.startsWith(prefix) ? min.slice(11) : null;
  const to = max?.startsWith(prefix) ? max.slice(11) : null;
  return { step: time.step ?? 1, ranges: trimRanges(windowRanges(time), from, to) };
}

// The date core's availability: the dates of `min` and `max`, and those dates when no time is left on them.
export function dateAvailability(availability = {}) {
  const { min, max, disabledDates = [], disabledWeekdays = [], disabledMonths = [], disabledYears = [] } = availability;
  const empty = [min, max]
    .filter((key) => key != null)
    .map((key) => key.slice(0, 10))
    .filter((key, index, keys) => keys.indexOf(key) === index && !disabledDates.includes(key))
    .filter((key) => noTimeOn(parseDateKey(key), availability));
  return {
    min: min?.slice(0, 10) ?? null,
    max: max?.slice(0, 10) ?? null,
    disabledDates: [...disabledDates, ...empty],
    disabledWeekdays,
    disabledMonths,
    disabledYears,
  };
}

// Problems that make availability unusable, each starting with the option it names; empty when valid.
export function availabilityErrors(availability = {}) {
  const { min, max, time = {}, ...dates } = availability;
  const errors = [];
  if (min != null && !parseDateTimeKey(min)) errors.push('min must be a date-time key');
  if (max != null && !parseDateTimeKey(max)) errors.push('max must be a date-time key');
  if (parseDateTimeKey(min) && parseDateTimeKey(max) && min > max) errors.push('min is after max');
  errors.push(...dateErrors(dates), ...timeErrors(time).map((error) => `time.${error}`));
  if (!errors.length && noTimeBetween(availability)) errors.push('min and max leave no time in the daily window');
  return errors;
}

// `min` and `max` fall on the same or neighbouring dates, and neither date has a time left.
function noTimeBetween(availability) {
  const { min, max } = availability;
  if (min == null || max == null) return false;

  const first = parseDateKey(min.slice(0, 10));
  const last = parseDateKey(max.slice(0, 10));
  return daysBetween(first, last) <= 1 && [first, last].every((date) => noTimeOn(date, availability));
}

// No time is left on a date once the daily window is trimmed at `min` and `max`.
function noTimeOn(date, availability) {
  return isEmpty(dayAvailability(date, availability));
}
