/** Matches a 24-hour time: HH:MM */
const H24_PATTERN = /^([01]?\d|2[0-3]):([0-5]\d)$/;

/** Matches the canonical form: HH:MM, 00:00–23:59 */
const CANONICAL_PATTERN = /^([01]\d|2[0-3]):([0-5]\d)$/;

const pad = (number) => String(number).padStart(2, '0');

export const TimeFormatter = {
  /**
   * Converts raw input to canonical 24-hour form: HH:MM.
   * Accepts HH:MM (24h) and h:mm AM/PM (12h); other text is returned trimmed.
   * @param {string} raw
   * @returns {string} "HH:MM", the trimmed text, or "" for non-string input or an out-of-range 12-hour time
   */
  normalize(raw) {
    if (typeof raw !== 'string') return '';
    const trimmed = raw.trim();

    if (H24_PATTERN.test(trimmed)) {
      const [h, m] = trimmed.split(':');
      return `${pad(parseInt(h, 10))}:${m}`;
    }

    // h:mm AM/PM
    const ampm = trimmed.match(/^(\d{1,2}):(\d{2})\s*(AM|PM)$/i);
    if (ampm) {
      let h = parseInt(ampm[1], 10);
      const m = ampm[2];
      const meridiem = ampm[3].toUpperCase();
      if (meridiem === 'AM') h = h === 12 ? 0 : h;
      else h = h === 12 ? 12 : h + 12;
      if (h > 23 || parseInt(m, 10) > 59) return '';
      return `${pad(h)}:${m}`;
    }

    return trimmed;
  },

  /**
   * Validates that the value is a parseable time.
   * @param {string} value
   * @returns {boolean}
   */
  validate(value) {
    return CANONICAL_PATTERN.test(TimeFormatter.normalize(value));
  },

  /**
   * Formats a canonical HH:MM value for display using Intl.DateTimeFormat.
   * Options other than `locale` are Intl options; hour and minute show unless `timeStyle` is given.
   * @param {string} value - Canonical "HH:MM" from normalize()
   * @param {Object} [opts={}]
   * @param {string} [opts.locale='en-US'] - BCP 47 locale tag
   * @param {string} [opts.hourCycle] - Intl hour cycle, e.g. 'h12' or 'h23'
   * @returns {string} Formatted time, or value as-is for invalid input
   */
  format(value, opts = {}) {
    if (typeof value !== 'string') return '';
    const match = value.match(CANONICAL_PATTERN);
    if (!match) return value;
    const { locale, ...options } = opts;
    const fields = options.timeStyle ? {} : { hour: 'numeric', minute: '2-digit' };
    try {
      return new Intl.DateTimeFormat(locale || 'en-US', { ...fields, ...options, timeZone: 'UTC' }).format(
        new Date(Date.UTC(1970, 0, 1, Number(match[1]), Number(match[2])))
      );
    } catch {
      return value;
    }
  },
};
