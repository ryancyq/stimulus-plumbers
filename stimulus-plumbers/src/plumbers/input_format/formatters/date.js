/** Matches an ISO 8601 date: YYYY-MM-DD */
const ISO_DATE_PATTERN = /^\d{4}-\d{2}-\d{2}$/;

/** Matches a date with separators: number-sep-number-sep-number (/, -, or .) */
const SEPARATED_DATE_PATTERN = /^(\d{1,4})[/\-.](\d{1,2})[/\-.](\d{1,4})$/;

/** Strips all non-digit characters (used when extracting 8-digit compact dates) */
const STRIP_NON_DIGITS = /\D/g;

export const DateInputFormatter = {
  /**
   * Converts raw input to the canonical stored form: ISO 8601 YYYY-MM-DD.
   * Accepts a variety of common date formats:
   *   - YYYY-MM-DD (ISO, returned unchanged)
   *   - MM/DD/YYYY, DD/MM/YYYY, YYYY/MM/DD (with /, -, or . separators)
   *   - YYYYMMDD (8 compact digits, first 4 digits treated as year)
   * When the first component of a separated date is 4 digits, it is treated as the year.
   * Otherwise, MM/DD/YYYY ordering is assumed.
   * @param {string} raw - Raw input in any supported format
   * @returns {string} ISO date string (YYYY-MM-DD), or '' for non-string input
   */
  normalize(raw) {
    if (typeof raw !== 'string') return '';
    const trimmed = raw.trim();

    // Already ISO YYYY-MM-DD
    if (ISO_DATE_PATTERN.test(trimmed)) return trimmed;

    // Date with separators: MM/DD/YYYY, DD/MM/YYYY, or YYYY/MM/DD
    const sepMatch = trimmed.match(SEPARATED_DATE_PATTERN);
    if (sepMatch) {
      const [, a, b, c] = sepMatch;
      if (a.length === 4) {
        return `${a}-${b.padStart(2, '0')}-${c.padStart(2, '0')}`;
      }
      if (c.length === 4) {
        // Default MM/DD/YYYY assumption
        return `${c}-${a.padStart(2, '0')}-${b.padStart(2, '0')}`;
      }
    }

    // 8 pure digits: YYYYMMDD or MMDDYYYY
    const digits = trimmed.replace(STRIP_NON_DIGITS, '');
    if (digits.length === 8) {
      const potentialYear = parseInt(digits.slice(0, 4), 10);
      if (potentialYear >= 1000 && potentialYear <= 9999) {
        return `${digits.slice(0, 4)}-${digits.slice(4, 6)}-${digits.slice(6, 8)}`;
      }
      return `${digits.slice(4, 8)}-${digits.slice(0, 2)}-${digits.slice(2, 4)}`;
    }

    return trimmed;
  },

  /**
   * Validates the input, accepting any format supported by normalize().
   * Internally normalizes to ISO form first, then checks calendar validity.
   * e.g. validate('04/13/2025') → true, validate('2025-02-29') → false (not a leap year)
   * @param {string} value - Input in any format (ISO, MM/DD/YYYY, etc.)
   * @returns {boolean}
   */
  validate(value) {
    if (typeof value !== 'string') return false;
    const iso = DateInputFormatter.normalize(value);
    if (!ISO_DATE_PATTERN.test(iso)) return false;
    const date = new Date(`${iso}T00:00:00Z`);
    return !isNaN(date.getTime()) && date.toISOString().startsWith(iso);
  },

  /**
   * Formats an ISO date string for display using Intl.DateTimeFormat.
   * All Intl options are configurable; defaults produce MM/DD/YYYY in en-US.
   * @param {string} value - Canonical ISO date string (YYYY-MM-DD) from normalize()
   * @param {Object} [opts={}] - Options
   * @param {string} [opts.locale='en-US'] - BCP 47 locale tag
   * @param {string} [opts.timeZone='UTC'] - IANA time zone
   * @param {string} [opts.year='numeric'] - Intl year format
   * @param {string} [opts.month='2-digit'] - Intl month format
   * @param {string} [opts.day='2-digit'] - Intl day format
   * @returns {string} Formatted date string, or value as-is for invalid input
   */
  format(value, opts = {}) {
    if (typeof value !== 'string') return '';
    const date = new Date(`${value}T00:00:00Z`);
    if (isNaN(date.getTime())) return value;
    const locale = opts.locale || 'en-US';
    try {
      return new Intl.DateTimeFormat(locale, {
        year: opts.year || 'numeric',
        month: opts.month || '2-digit',
        day: opts.day || '2-digit',
        timeZone: opts.timeZone || 'UTC',
      }).format(date);
    } catch {
      return value;
    }
  },
};
