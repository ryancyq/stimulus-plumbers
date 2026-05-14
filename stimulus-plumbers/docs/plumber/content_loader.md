# ContentLoader

Handles async content fetching with lifecycle hooks and staleness control. Exposes `this.load()` on the controller. Used by `popover`.

## Factory

```js
import { attachContentLoader } from '../plumbers';
attachContentLoader(controller, options);
```

Exposes `this.load()` on the controller.

## Options

| Option      | Type        | Default            | Description                                                                             |
| ----------- | ----------- | ------------------ | --------------------------------------------------------------------------------------- |
| `element`   | HTMLElement | `null`             | Target element (informational — passed to dispatches)                                   |
| `url`       | String      | `''`               | Remote URL to fetch content from                                                        |
| `reload`    | String      | `'never'`          | Reload strategy: `'never'`, `'always'`, or `'stale'`                                    |
| `stale`     | Number      | `3600`             | Seconds before cached content is considered stale (only applies when `reload: 'stale'`) |
| `onLoad`    | String      | `'canLoad'`        | Controller method that returns `true` if loading should proceed                         |
| `onLoading` | String      | `'contentLoading'` | Controller method called when loading begins                                            |
| `onLoaded`  | String      | `'contentLoaded'`  | Controller method called with the loaded content                                        |

## Controller method — `this.load()`

Runs the load lifecycle:

1. Calls `onLoad` (or default `contentLoadable`) — skips if returns falsy
2. Fetches content from `url` or falls back to `contentLoader()`
3. Calls `onLoaded({ url, content })` with the result

Skips entirely if content was already loaded and the reload strategy is `'never'`. For `'stale'`, compares `loadedAt` against `stale` seconds.

## Controller callbacks

| Callback                          | Signature         | Description                                     |
| --------------------------------- | ----------------- | ----------------------------------------------- |
| `canLoad()`                       | `() → boolean`    | Return `false` to prevent loading               |
| `contentLoading()`                | `async () → void` | Called when loading begins (show spinner, etc.) |
| `contentLoaded({ url, content })` | `async () → void` | Handle the loaded content                       |

## Dispatches

| Event              | Detail             | When                    |
| ------------------ | ------------------ | ----------------------- |
| `{prefix}:load`    | `{ url }`          | Before load check       |
| `{prefix}:loading` | `{ url }`          | After load check passes |
| `{prefix}:loaded`  | `{ url, content }` | After content is ready  |

## Reload strategies

| `reload`   | Behaviour                                          |
| ---------- | -------------------------------------------------- |
| `'never'`  | Load once; subsequent `load()` calls are no-ops    |
| `'always'` | Reload every time `load()` is called               |
| `'stale'`  | Reload if `loadedAt` is older than `stale` seconds |
