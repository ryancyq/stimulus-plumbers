# ContentLoader

Handles async content fetching with lifecycle hooks and staleness control. Exposes `this.load()` on the controller. Used by `popover`.

## Factory

```js
import { attachContentLoader } from '../plumbers';
attachContentLoader(controller, options);
```

## Options

| Option     | Type        | Default           | Description                                                                             |
| ---------- | ----------- | ----------------- | --------------------------------------------------------------------------------------- |
| `element`  | HTMLElement | `null`            | Target element (informational — passed to dispatches)                                   |
| `url`      | String      | `''`              | Remote URL to fetch content from                                                        |
| `reload`   | String      | `'never'`         | Reload strategy: `'never'`, `'always'`, or `'stale'`                                    |
| `stale`    | Number      | `3600`            | Seconds before cached content is considered stale (only applies when `reload: 'stale'`) |
| `onLoad`   | String      | `'canLoad'`       | Controller method that returns `true` if loading should proceed                         |
| `onLoaded` | String      | `'contentLoaded'` | Controller method called with the loaded content                                        |

## Controller method — `this.load()`

1. Calls `onLoad` — skips if returns falsy
2. Dispatches `loading`
3. Fetches from `url` or falls back to `contentLoader()`
4. Calls `onLoaded({ url, content })`

## Controller callbacks

| Callback                          | Signature         | Description                       |
| --------------------------------- | ----------------- | --------------------------------- |
| `canLoad()`                       | `() → boolean`    | Return `false` to prevent loading |
| `contentLoaded({ url, content })` | `async () → void` | Handle the loaded content         |

## Dispatches

| Event              | Detail             | When                                   |
| ------------------ | ------------------ | -------------------------------------- |
| `{prefix}:load`    | `{ url }`          | Before load check                      |
| `{prefix}:loading` | `{ url }`          | After load check passes (before fetch) |
| `{prefix}:loaded`  | `{ url, content }` | After content is ready                 |

## Reload strategies

| `reload`   | Behaviour                                          |
| ---------- | -------------------------------------------------- |
| `'never'`  | Load once; subsequent `load()` calls are no-ops    |
| `'always'` | Reload every time `load()` is called               |
| `'stale'`  | Reload if `loadedAt` is older than `stale` seconds |
