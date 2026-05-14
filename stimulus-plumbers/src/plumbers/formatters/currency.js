/** Strips everything except digits, period, comma, and negative sign */
const STRIP_NON_NUMERIC = /[^\d.,-]/g;

/** Matches a valid canonical amount: optional negative sign, digits, optional decimal part */
const VALID_AMOUNT_PATTERN = /^-?\d+(\.\d+)?$/;

export const CurrencyFormatter = {
  /**
   * Converts raw input to the canonical stored form: a plain decimal number string.
   * Handles US format (1,234.56), European format (1.234,56), and integers ($1,000).
   * The heuristic for ambiguous comma-only input: ≤2 digits after comma → decimal
   * separator; 3 digits after → thousands separator.
   * @param {string} raw - Raw input (may contain currency symbols, separators)
   * @returns {string} Canonical decimal string (e.g. '1234.56'), or '' for non-string/empty
   */
  normalize(raw) {
    if (typeof raw !== 'string') return '';
    const stripped = raw.replace(STRIP_NON_NUMERIC, '');
    if (!stripped) return '';
    const lastComma = stripped.lastIndexOf(',');
    const lastDot = stripped.lastIndexOf('.');

    if (lastComma > -1 && lastDot > -1) {
      // Both present: the later one is the decimal separator
      if (lastComma > lastDot) {
        // European: 1.234,56 — comma is decimal, dot is thousands
        return stripped.replace(/\./g, '').replace(',', '.');
      }
      // US: 1,234.56 — dot is decimal, comma is thousands
      return stripped.replace(/,/g, '');
    }

    if (lastComma > -1) {
      // Comma only: 1-2 digits after = decimal separator; 3 digits after = thousands separator
      const afterComma = stripped.slice(lastComma + 1);
      if (afterComma.length <= 2) return stripped.replace(',', '.');
      return stripped.replace(/,/g, '');
    }

    // Dot only or no separator
    return stripped;
  },

  /**
   * Validates the canonical amount: optional negative sign, integer digits,
   * and an optional decimal part of any length.
   * @param {string} value - Canonical value from normalize()
   * @returns {boolean}
   */
  validate(value) {
    if (typeof value !== 'string') return false;
    return VALID_AMOUNT_PATTERN.test(value);
  },

  /**
   * Formats a canonical amount for display using Intl.NumberFormat.
   * Fraction digit defaults come from the currency itself (e.g. JPY uses 0,
   * USD uses 2, KWD uses 3) — no hardcoded overrides unless opts.fractionDigits
   * is explicitly provided.
   * @param {string} value - Canonical value from normalize()
   * @param {Object} [opts={}] - Options
   * @param {string} [opts.locale='en-US'] - BCP 47 locale tag
   * @param {string} [opts.currency='USD'] - ISO 4217 currency code
   * @param {number} [opts.fractionDigits] - Override min and max fraction digits
   * @returns {string} Formatted currency string, or value as-is for non-numeric input
   */
  format(value, opts = {}) {
    if (typeof value !== 'string') return '';
    const num = parseFloat(value);
    if (isNaN(num)) return value;
    const locale = opts.locale || 'en-US';
    const currency = opts.currency || 'USD';
    const fractionOpts =
      opts.fractionDigits !== undefined
        ? { minimumFractionDigits: opts.fractionDigits, maximumFractionDigits: opts.fractionDigits }
        : {};
    try {
      return new Intl.NumberFormat(locale, {
        style: 'currency',
        currency,
        ...fractionOpts,
      }).format(num);
    } catch {
      return value;
    }
  },
};
