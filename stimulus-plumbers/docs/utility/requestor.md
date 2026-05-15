# Requestor

HTTP transport with debounce and abort. Returns a raw `Response` — caller decides `.text()` or `.json()`.

## Import

```js
import { Requestor } from '@stimulus-plumbers/controllers';
```

## API

### `new Requestor()`

Creates an instance. One per controller.

### `requestor.schedule(fn, delay)`

Debounces `fn` by `delay` milliseconds. Cancels any previously scheduled call.

| Param   | Type     | Description                    |
| ------- | -------- | ------------------------------ |
| `fn`    | Function | Zero-argument function to call |
| `delay` | Number   | Debounce delay in milliseconds |

### `requestor.request(url, options?)`

Issues a `fetch`. Aborts any in-flight request before starting.

| Param     | Type        | Description                              |
| --------- | ----------- | ---------------------------------------- |
| `url`     | String\|URL | Request URL                              |
| `options` | Object      | `fetch` options (merged with the signal) |

Returns `Promise<Response>`. Rejects with `Error` on non-ok status, `AbortError` on cancel.

### `requestor.cancel()`

Aborts the in-flight request and clears the debounce timer.

## Usage

```js
initialize() {
  this._requestor = new Requestor();
}

filter(query) {
  const url = new URL('/search', window.location.href);
  url.searchParams.set('q', query);

  this._requestor.schedule(
    () =>
      this._requestor
        .request(url)
        .then((r) => r.text())
        .then((html) => { this.listTarget.innerHTML = html; })
        .catch((err) => { if (err.name !== 'AbortError') console.error(err); }),
    300
  );
}

disconnect() {
  this._requestor.cancel();
}
```
