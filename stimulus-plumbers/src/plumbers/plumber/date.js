const DATE_ONLY_PATTERN = /^\d{4}-\d{2}-\d{2}$/;

export function isValidDate(value) {
  return value instanceof Date && !isNaN(value);
}

export function tryParseDate(...values) {
  if (values.length === 0) throw 'Missing values to parse as date';
  if (values.length === 1) {
    const dateValue = values[0];
    if (!dateValue) return undefined;
    if (typeof dateValue === 'string' && DATE_ONLY_PATTERN.test(dateValue)) {
      // YYYY-MM-DD strings are UTC by spec; use local constructor instead
      const [year, month, day] = dateValue.split('-').map(Number);
      const parsed = new Date(year, month - 1, day);
      if (isValidDate(parsed)) return parsed;
    } else {
      const parsed = new Date(dateValue);
      if (isValidDate(parsed)) return parsed;
    }
  } else {
    const parsed = new Date(...values);
    if (isValidDate(parsed)) return parsed;
  }
}
