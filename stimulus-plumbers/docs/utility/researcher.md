# Researcher

Client-side string matching.

## Import

```js
import { fuzzyMatcher } from '@stimulus-plumbers/controllers';
```

---

## `fuzzyMatcher(needle, haystack)`

Returns `true` when all characters of `needle` appear in `haystack` in order (case-sensitive).

```js
fuzzyMatcher('apl', 'apple'); // true
fuzzyMatcher('ppa', 'apple'); // false
fuzzyMatcher('', 'anything'); // true
```
