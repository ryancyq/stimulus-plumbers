/**
 * Validates a credit card number string using the Luhn algorithm.
 *
 * Starting from the rightmost digit, double every second digit. If doubling
 * produces a number greater than 9, subtract 9 from it. Sum all digits.
 * A valid card number produces a total divisible by 10.
 *
 * @param {string} digits - Digit-only string (no spaces or dashes)
 * @returns {boolean} true if the number passes the Luhn check
 */
function luhn(digits) {
  let sum = 0;
  let alternate = false;
  for (let i = digits.length - 1; i >= 0; i--) {
    let n = parseInt(digits[i], 10);
    if (alternate) {
      n *= 2;
      if (n > 9) n -= 9;
    }
    sum += n;
    alternate = !alternate;
  }
  return sum % 10 === 0;
}

/** Strips all non-digit characters from raw input */
const STRIP_NON_DIGITS = /\D/g;

/** Matches a valid card digit count (13–19 digits, no other characters) */
const VALID_CARD_LENGTH = /^\d{13,19}$/;

const AMEX_PREFIX = /^3[47]/;

const givenGroups = (options) => (Array.isArray(options.groups) && options.groups.length > 0 ? options.groups : null);

/** `options.groups`, else 4-6-5 for an Amex number, else 4-4-4-4 */
const groupsOf = (value, options) => givenGroups(options) ?? (AMEX_PREFIX.test(value) ? [4, 6, 5] : [4, 4, 4, 4]);

function maxDigits(value, options) {
  const groups = givenGroups(options);
  if (groups) return groups.reduce((sum, size) => sum + size, 0);
  return AMEX_PREFIX.test(value) ? 15 : 19;
}

/** Splits value at each group size; digits past the groups' sum form a trailing group */
function groupDigits(value, groups, separator) {
  const parts = [];
  let start = 0;
  for (const size of groups) {
    if (start >= value.length) break;
    parts.push(value.slice(start, start + size));
    start += size;
  }
  if (start < value.length) parts.push(value.slice(start));
  return parts.join(separator);
}

export const CreditCardFormatter = {
  /**
   * Converts raw input to the canonical stored form: digits only, no separators, capped at
   * the `options.groups` sum, else 15 digits for Amex, else 19.
   * e.g. '4242 4242 4242 4242' → '4242424242424242'
   * @param {string} raw - Raw input (may contain spaces, dashes, etc.)
   * @param {{ groups?: number[] }} [options]
   * @returns {string} Digit-only string, or '' for non-string input
   */
  normalize(raw, options = {}) {
    if (typeof raw !== 'string') return '';
    const digits = raw.replace(STRIP_NON_DIGITS, '');
    return digits.slice(0, maxDigits(digits, options));
  },

  /**
   * Validates the canonical card number using length and Luhn checks.
   * Expects the output of normalize() — digits only.
   * @param {string} value - Canonical value from normalize()
   * @returns {boolean}
   */
  validate(value) {
    if (typeof value !== 'string') return false;
    if (!VALID_CARD_LENGTH.test(value)) return false;
    return luhn(value);
  },

  /**
   * Formats a canonical card number for display: digits grouped as `options.groups`, else
   * 4-6-5 for Amex, else 4-4-4-4, joined by `options.separator` (a space by default).
   * e.g. '4242424242424242' → '4242 4242 4242 4242'; '378282246310005' → '3782 822463 10005'
   * @param {string} value - Canonical value from normalize()
   * @param {{ groups?: number[], separator?: string }} [options]
   * @returns {string} Formatted display string, or '' for non-string input
   */
  format(value, options = {}) {
    if (typeof value !== 'string') return '';
    return groupDigits(value, groupsOf(value, options), options.separator ?? ' ');
  },

  /**
   * CharacterCells hint: four groups of four digits (standard 16-digit PAN). No fixed
   * length — validate() accepts 13-19 digits, so length derives from the rendered cells
   * (or an author-supplied `groups` override for non-16-digit PANs) rather than being
   * capped here.
   * @returns {{ groups: number[], length: number }}
   */
  cells() {
    return { groups: [4, 4, 4, 4], length: 0 };
  },
};
