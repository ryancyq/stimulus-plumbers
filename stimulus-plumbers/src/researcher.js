import { setHidden } from './accessibility/aria';

export function fuzzyMatcher(needle, haystack) {
  let ni = 0;
  for (let i = 0; i < haystack.length && ni < needle.length; i++) {
    if (haystack[i] === needle[ni]) ni++;
  }
  return ni === needle.length;
}

function matchContains(needle, haystack) {
  return haystack.includes(needle);
}

function matchPrefix(needle, haystack) {
  return haystack.startsWith(needle);
}

function getStrategy(strategy) {
  if (strategy === 'contains') return matchContains;
  if (strategy === 'prefix') return matchPrefix;
  return fuzzyMatcher;
}

function extractDOMValue(el, field) {
  if (field === 'textContent') return el.textContent?.trim().toLowerCase() ?? '';
  return (el.getAttribute(field) ?? '').toLowerCase();
}

export function filterOptions(listbox, query, options = {}) {
  const { strategy = 'fuzzy', matcher, fields = ['textContent'] } = options;
  const matchFn = typeof matcher === 'function' ? matcher : getStrategy(strategy);
  const needle = query.toLowerCase();
  let visible = 0;
  listbox.querySelectorAll('[role="option"]').forEach((opt) => {
    const match = fields.some((field) => matchFn(needle, extractDOMValue(opt, field)));
    setHidden(opt, !match);
    if (match) visible++;
  });
  return visible;
}
