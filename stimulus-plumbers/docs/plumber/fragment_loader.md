# FragmentLoader plumber

`FragmentLoader` fetches HTML and replaces a target element with the response element of the same `id`.
Used by [`combobox-fetch`](../component/combobox.md#combobox-fetch) and
[`popover-fetch`](../component/popover.md#popover-fetch).

```js
import { attachFragmentLoader } from '@stimulus-plumbers/controllers';

const loader = attachFragmentLoader(controller, { element: controller.regionTarget });
const region = await loader.load('/menu'); // the swapped-in element, or null when cancelled
loader.cancel();
loader.disconnect();
```

## Options

| Option    | Type        | Default | Description                                                                       |
| --------- | ----------- | ------- | --------------------------------------------------------------------------------- |
| `element` | HTMLElement | —       | Element to replace; it needs an `id` and must not be the controller's own element |

Without a valid `element` the loader is inert and `load()` resolves `null`.

## Members

| Member         | Description                                                                                                    |
| -------------- | -------------------------------------------------------------------------------------------------------------- |
| `element`      | The current target; each load replaces it                                                                      |
| `busy`         | Whether a load is in flight                                                                                    |
| `load(url)`    | Cancels any load in flight, then fetches `url`; resolves to the new element, `null` when cancelled, or rejects |
| `cancel()`     | Cancels the load in flight                                                                                     |
| `disconnect()` | Cancels and leaves the loader inert; safe to repeat                                                            |

- Requests send `Accept: text/html` and must stay on the page origin.
- The target carries `aria-busy="true"` while loading; a cancelled or failed load removes it.
- A failed response, or one without an element of the target's `id`, rejects and keeps the current element.
- The response must be trusted, server-escaped HTML; the loader does not sanitize it.

The plumber does not debounce, announce, or move focus.
