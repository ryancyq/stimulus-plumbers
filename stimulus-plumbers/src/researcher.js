export function fuzzyMatcher(needle, haystack) {
  let ni = 0;
  for (let i = 0; i < haystack.length && ni < needle.length; i++) {
    if (haystack[i] === needle[ni]) ni++;
  }
  return ni === needle.length;
}

export function matchContains(needle, haystack) {
  return haystack.includes(needle);
}

export function matchPrefix(needle, haystack) {
  return haystack.startsWith(needle);
}
