// Times of day as { hour, minute } with hour 0–23; never a Date or an instant.
// Time keys (HH:MM, 00:00–23:59) at the boundaries, parts for arithmetic.
const KEY_PATTERN = /^(\d{2}):(\d{2})$/;
const STEPS = [1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60];
export const HOURS = Array.from({ length: 24 }, (_, hour) => hour);

export function parseTimeKey(value) {
  const match = KEY_PATTERN.exec(value ?? '');
  if (!match) return null;

  const [hour, minute] = match.slice(1).map(Number);
  return hour < 24 && minute < 60 ? { hour, minute } : null;
}

export function timeKey({ hour, minute }) {
  return `${String(hour).padStart(2, '0')}:${String(minute).padStart(2, '0')}`;
}

// Availability uses time keys for `min` and `max`, a `min` after `max` wrapping past midnight, or `ranges` in place of
// both; `step` is minutes counted from midnight.
export function isDisabled(time, availability = {}) {
  const { step = 1, ranges = windowRanges(availability) } = availability;
  const key = timeKey(time);
  return !ranges.some(([start, end]) => key >= start && key <= end) || time.minute % step !== 0;
}

// The daily window as inclusive [start, end] time keys; a window that wraps past midnight is two ranges.
export function windowRanges({ min, max } = {}) {
  const [start, end] = [min ?? '00:00', max ?? '23:59'];
  return start > end
    ? [
        ['00:00', end],
        [start, '23:59'],
      ]
    : [[start, end]];
}

// Ranges that stop before `from` and after `to`, time keys or null.
export function trimRanges(ranges, from, to) {
  return ranges
    .map(([start, end]) => [from != null && from > start ? from : start, to != null && to < end ? to : end])
    .filter(([start, end]) => start <= end);
}

// An hour is unavailable when none of its minutes is.
export function isHourDisabled(hour, availability = {}) {
  return Array.from({ length: 60 }, (_, minute) => ({ hour, minute })).every((time) => isDisabled(time, availability));
}

// No hour has an available minute.
export function isEmpty(availability = {}) {
  return HOURS.every((hour) => isHourDisabled(hour, availability));
}

// Problems that make availability unusable, each starting with the option it names; empty when valid.
export function availabilityErrors(availability = {}) {
  const { min, max, step = 1 } = availability;
  const errors = [];
  if (min != null && !parseTimeKey(min)) errors.push('min must be a time key');
  if (max != null && !parseTimeKey(max)) errors.push('max must be a time key');
  if (!STEPS.includes(step)) errors.push(`step must be one of ${STEPS.join(', ')}`);
  if (!errors.length && isEmpty(availability)) errors.push('min and max leave no time on the step');
  return errors;
}
