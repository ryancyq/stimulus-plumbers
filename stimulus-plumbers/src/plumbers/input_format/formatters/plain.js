export const PlainInputFormatter = {
  normalize(raw) {
    if (typeof raw !== 'string') return '';
    return raw;
  },

  validate() {
    return true;
  },
};
