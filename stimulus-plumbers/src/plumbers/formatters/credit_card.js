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

/** Captures groups of up to 4 characters followed by at least one more character */
const GROUP_FOUR_DIGITS = /(.{4})(?=.)/g;

export const CreditCardFormatter = {
  /**
   * Converts raw input to the canonical stored form: digits only, no separators.
   * e.g. '4242 4242 4242 4242' → '4242424242424242'
   * @param {string} raw - Raw input (may contain spaces, dashes, etc.)
   * @returns {string} Digit-only string, or '' for non-string input
   */
  normalize(raw) {
    if (typeof raw !== 'string') return '';
    return raw.replace(STRIP_NON_DIGITS, '');
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
   * Formats a canonical card number for display: groups of 4 separated by spaces.
   * e.g. '4242424242424242' → '4242 4242 4242 4242'
   * @param {string} value - Canonical value from normalize()
   * @returns {string} Formatted display string, or '' for non-string input
   */
  format(value) {
    if (typeof value !== 'string') return '';
    return value.replace(GROUP_FOUR_DIGITS, '$1 ');
  },
};
