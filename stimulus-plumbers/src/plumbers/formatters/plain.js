export const PlainFormatter = {
  normalize(raw) {
    if (typeof raw !== 'string') return '';
    return raw;
  },

  validate() {
    return true;
  },
};
