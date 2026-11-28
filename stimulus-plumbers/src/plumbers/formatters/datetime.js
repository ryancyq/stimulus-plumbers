import { parseDateTimeKey } from '../../datetime';

export const DatetimeFormatter = {
  /**
   * Trims raw input; the canonical form is a date-time key, YYYY-MM-DDTHH:MM.
   * @param {string} raw
   * @returns {string} The trimmed text, or "" for non-string input
   */
  normalize(raw) {
    return typeof raw === 'string' ? raw.trim() : '';
  },

  /**
   * Validates that the value is a date-time key.
   * @param {string} value
   * @returns {boolean}
   */
  validate(value) {
    return parseDateTimeKey(DatetimeFormatter.normalize(value)) !== null;
  },

  /**
   * Formats a date-time key for display using Intl.DateTimeFormat, on the wall clock.
   * Options other than `locale` are Intl options; the date and time fields show unless `dateStyle` or
   * `timeStyle` is given.
   * @param {string} value - Date-time key (YYYY-MM-DDTHH:MM)
   * @param {Object} [opts={}]
   * @param {string} [opts.locale='en-US'] - BCP 47 locale tag
   * @returns {string} Formatted date-time, or value as-is for invalid input
   */
  format(value, opts = {}) {
    if (typeof value !== 'string') return '';
    if (!parseDateTimeKey(value)) return value;
    const { locale, ...options } = opts;
    const fields =
      options.dateStyle || options.timeStyle
        ? {}
        : { year: 'numeric', month: '2-digit', day: '2-digit', hour: 'numeric', minute: '2-digit' };
    try {
      return new Intl.DateTimeFormat(locale || 'en-US', { ...fields, ...options, timeZone: 'UTC' }).format(
        new Date(`${value}:00Z`)
      );
    } catch {
      return value;
    }
  },
};
