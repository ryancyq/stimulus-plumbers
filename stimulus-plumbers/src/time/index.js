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

// Availability uses time keys for `min` and `max`, a `min` after `max` wrapping past midnight; `step` is minutes
// counted from midnight.
export function isDisabled(time, availability = {}) {
  const { min, max, step = 1 } = availability;
  return outsideWindow(timeKey(time), min, max) || time.minute % step !== 0;
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

// Before `min` or after `max`; between them when the window wraps past midnight.
function outsideWindow(key, min, max) {
  if (min != null && max != null && min > max) return key < min && key > max;
  return (min != null && key < min) || (max != null && key > max);
}
