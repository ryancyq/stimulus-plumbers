/**
 * Map of E.164 country calling code → expected local digit count.
 * Key: calling code string (without '+').
 * Value: local number digit count (excluding the country code).
 *
 * Example: '1' → 10 means USA/Canada use a 10-digit local number
 * (3-digit area code + 7-digit subscriber number).
 *
 * Extend this object to add formatting support for additional countries.
 */
const DIALING_CODE_LOCAL_DIGITS = {
  1: 10, // USA, Canada, and NANP countries
};

/** Strips all non-digit characters */
const STRIP_NON_DIGITS = /\D/g;

/** Matches an E.164 international phone number: + followed by 7–15 digits */
const E164_PATTERN = /^\+\d{7,15}$/;

export const PhoneInputFormatter = {
  /**
   * Converts raw input to canonical form.
   * If input starts with '+', produces E.164 (+digits); otherwise strips to digits only.
   * e.g. '(555) 123-4567' → '5551234567', '+1 555 123 4567' → '+15551234567'
   * @param {string} raw - Raw input (may contain spaces, dashes, parentheses, etc.)
   * @returns {string} Canonical string, or '' for non-string input
   */
  normalize(raw) {
    if (typeof raw !== 'string') return '';
    const hasPlus = raw.trimStart().startsWith('+');
    const digits = raw.replace(STRIP_NON_DIGITS, '');
    return hasPlus ? `+${digits}` : digits;
  },

  /**
   * Validates the canonical phone number.
   * Accepts E.164 format or a local number whose digit count appears in DIALING_CODE_LOCAL_DIGITS.
   * @param {string} value - Canonical value from normalize()
   * @returns {boolean}
   */
  validate(value) {
    if (typeof value !== 'string') return false;
    if (E164_PATTERN.test(value)) return true;
    const digits = value.replace(STRIP_NON_DIGITS, '');
    return Object.values(DIALING_CODE_LOCAL_DIGITS).includes(digits.length);
  },

  /**
   * Formats a canonical phone number for display.
   * Recognises numbers matching entries in DIALING_CODE_LOCAL_DIGITS.
   * e.g. '5551234567' → '(555) 123-4567', '+15551234567' → '+1 (555) 123-4567'
   * Returns value unchanged for unrecognised international numbers.
   * @param {string} value - Canonical value from normalize()
   * @returns {string} Formatted display string, or '' for non-string input
   */
  format(value) {
    if (typeof value !== 'string') return '';
    const digits = value.replace(STRIP_NON_DIGITS, '');
    for (const [code, localDigits] of Object.entries(DIALING_CODE_LOCAL_DIGITS)) {
      if (digits.length === localDigits) {
        // Local number without country code prefix
        return `(${digits.slice(0, 3)}) ${digits.slice(3, 6)}-${digits.slice(6)}`;
      }
      const totalWithCode = localDigits + code.length;
      if (digits.length === totalWithCode && digits.startsWith(code)) {
        const local = digits.slice(code.length);
        return `+${code} (${local.slice(0, 3)}) ${local.slice(3, 6)}-${local.slice(6)}`;
      }
    }
    return value;
  },
};
