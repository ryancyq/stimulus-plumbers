/** Strip patterns per charset — everything NOT in the charset is removed */
const CHARSETS = {
  digits: /[^0-9]/g,
  letters: /[^a-zA-Z]/g,
  alphanumeric: /[^0-9a-zA-Z]/g,
};

export const CodeFormatter = {
  /**
   * Converts raw input to the canonical stored form: charset-filtered, uppercased,
   * truncated to `length` when set.
   * e.g. normalize('4 8-29 13', { charset: 'digits' }) → '482913'
   * @param {string} raw - Raw input
   * @param {Object} [opts={}] - Options
   * @param {string} [opts.charset='alphanumeric'] - 'digits' | 'letters' | 'alphanumeric'
   * @param {number} [opts.length=0] - Truncation length; 0 disables truncation
   * @returns {string} Canonical code string, or '' for non-string input
   */
  normalize(raw, opts = {}) {
    if (typeof raw !== 'string') return '';
    const strip = CHARSETS[opts.charset] ?? CHARSETS.alphanumeric;
    const value = raw.replace(strip, '').toUpperCase();
    const length = opts.length ?? 0;
    return length > 0 ? value.slice(0, length) : value;
  },

  /**
   * Validates the canonical code: exact length match when `length` is set.
   * @param {string} value - Canonical value from normalize()
   * @param {Object} [opts={}] - Options
   * @param {number} [opts.length=0] - Expected length; 0 accepts any
   * @returns {boolean}
   */
  validate(value, opts = {}) {
    if (typeof value !== 'string') return false;
    const length = opts.length ?? 0;
    return length > 0 ? value.length === length : true;
  },

  /**
   * Codes display as-is — CharacterCells handles visual chunking.
   * @param {string} value - Canonical value from normalize()
   * @returns {string}
   */
  format(value) {
    return typeof value === 'string' ? value : '';
  },

  /**
   * CharacterCells hint: uniform single-character cells, `length` cells expected.
   * @param {Object} [opts={}] - Formatter options
   * @returns {{ groups: number[], length: number }}
   */
  cells(opts = {}) {
    return { groups: [], length: opts.length ?? 0 };
  },
};
