/** Matches a 24-hour time: HH:MM */
const H24_PATTERN = /^([01]?\d|2[0-3]):([0-5]\d)$/;

export const TimeFormatter = {
  /**
   * Converts raw input to canonical 24-hour form: HH:MM.
   * Accepts HH:MM (24h) and h:mm AM/PM (12h).
   * @param {string} raw
   * @returns {string} "HH:MM" or "" for invalid input
   */
  normalize(raw) {
    if (typeof raw !== 'string') return '';
    const trimmed = raw.trim();

    if (H24_PATTERN.test(trimmed)) {
      const [h, m] = trimmed.split(':');
      return `${String(parseInt(h, 10)).padStart(2, '0')}:${m}`;
    }

    // h:mm AM/PM
    const ampm = trimmed.match(/^(\d{1,2}):(\d{2})\s*(AM|PM)$/i);
    if (ampm) {
      let h = parseInt(ampm[1], 10);
      const m = ampm[2];
      const period = ampm[3].toUpperCase();
      if (period === 'AM') h = h === 12 ? 0 : h;
      else h = h === 12 ? 12 : h + 12;
      if (h > 23 || parseInt(m, 10) > 59) return '';
      return `${String(h).padStart(2, '0')}:${m}`;
    }

    return '';
  },

  /**
   * Validates that the value is a parseable time.
   * @param {string} value
   * @returns {boolean}
   */
  validate(value) {
    return TimeFormatter.normalize(value) !== '';
  },

  /**
   * Formats a canonical HH:MM value for display.
   * @param {string} value - Canonical "HH:MM" from normalize()
   * @param {Object} [opts={}]
   * @param {string} [opts.format='h12'] - 'h12' or 'h24'
   * @returns {string}
   */
  format(value, opts = {}) {
    if (typeof value !== 'string') return '';
    const match = value.match(/^(\d{2}):(\d{2})$/);
    if (!match) return value;
    const h = parseInt(match[1], 10);
    const m = match[2];
    if (opts.format === 'h24') return `${String(h).padStart(2, '0')}:${m}`;
    const period = h < 12 ? 'AM' : 'PM';
    const displayH = h % 12 || 12;
    return `${displayH}:${m} ${period}`;
  },
};
