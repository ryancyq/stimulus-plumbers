# Researcher

Client-side option filtering for listbox/combobox components.

## Import

```js
import { fuzzyMatcher, filterOptions } from '@stimulus-plumbers/controllers';
```

---

## `fuzzyMatcher(needle, haystack)`

Returns `true` when all characters of `needle` appear in `haystack` in order (case-sensitive).

```js
fuzzyMatcher('apl', 'apple'); // true
fuzzyMatcher('ppa', 'apple'); // false
fuzzyMatcher('', 'anything'); // true
```

---

## `filterOptions(listbox, query, options?)`

Hides/shows `[role="option"]` elements inside `listbox`. Returns the visible count.

| Param     | Type        | Description                           |
| --------- | ----------- | ------------------------------------- |
| `listbox` | HTMLElement | Container holding `[role="option"]`s  |
| `query`   | String      | Search string (lowercased internally) |
| `options` | Object      | See options table below               |

### Options

| Option     | Type     | Default           | Description                                                              |
| ---------- | -------- | ----------------- | ------------------------------------------------------------------------ |
| `strategy` | String   | `'fuzzy'`         | `'fuzzy'`, `'contains'`, or `'prefix'`                                   |
| `matcher`  | Function | —                 | Custom `(needle, haystack) → boolean` — overrides `strategy` if provided |
| `fields`   | String[] | `['textContent']` | Attributes or `'textContent'` to match against (any field can match)     |

### Strategies

| Strategy     | Behaviour                                       |
| ------------ | ----------------------------------------------- |
| `'fuzzy'`    | Characters of query appear in order in the text |
| `'contains'` | Text contains the query substring               |
| `'prefix'`   | Text starts with the query string               |

### Examples

```js
// Default fuzzy filter
filterOptions(listboxEl, 'apl');

// Match against a data attribute
filterOptions(listboxEl, 'united', { fields: ['data-label'] });

// Match against multiple fields
filterOptions(listboxEl, 'us', { fields: ['textContent', 'data-value'] });

// Custom matcher
filterOptions(listboxEl, 'Apple', {
  matcher: (needle, haystack) => haystack === needle,
});
```
