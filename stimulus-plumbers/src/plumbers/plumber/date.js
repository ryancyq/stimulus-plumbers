export function isValidDate(value) {
  return value instanceof Date && !isNaN(value);
}

export function tryParseDate(...values) {
  if (values.length === 0) throw 'Missing values to parse as date';
  if (values.length === 1) {
    const parsed = new Date(values[0]);
    if (values[0] && isValidDate(parsed)) return parsed;
  } else {
    const parsed = new Date(...values);
    if (isValidDate(parsed)) return parsed;
  }
}
