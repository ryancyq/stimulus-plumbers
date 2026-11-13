# popover

Adapts a native `popover` element to the popover lifecycle through the [popover plumber](../plumber/popover.md).
The browser owns the top layer, light dismissal, and Escape for `popover="auto"`; the consuming component owns
role, keyboard behavior, focus, and selection.

```html
<div data-controller="popover">
  <button data-popover-target="trigger" popovertarget="account-actions">Account</button>
  <div id="account-actions" data-popover-target="panel" popover="auto" role="region" aria-label="Account actions">
    <turbo-frame id="account_actions" src="/menu" loading="lazy"></turbo-frame>
  </div>
</div>
```

## Targets

| Target    | Required | Description                                                     |
| --------- | -------- | --------------------------------------------------------------- |
| `trigger` | no       | Default source for programmatic opens                           |
| `panel`   | yes      | Native popover element (`popover="auto"` or `popover="manual"`) |

## Methods

| Method            | Description                                                                                                                                     |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `onOpen(event)`   | Event adapter — opens with the event's current target as the source                                                                             |
| `onClose(event)`  | Event adapter — closes                                                                                                                          |
| `onToggle(event)` | Event adapter — toggles with the event's current target as the source                                                                           |
| `onFocus(event)`  | `focus->popover#onFocus` opens on focus, except before any user input since connect, when focus returns from the panel, or inside an open modal |
| `open(source?)`   | Opens the panel; the source defaults to the `trigger` target                                                                                    |
| `close()`         | Closes the panel                                                                                                                                |
| `toggle(source?)` | Toggles the panel; the source defaults to the `trigger` target                                                                                  |

The packaged button opens declaratively with `popovertarget` and needs no action. A custom source wires its own,
e.g. `click->popover#onOpen` on an input. Light dismissal treats a custom source as outside the panel, so with
`popover="auto"` it can open the panel but not toggle it closed. Direct calls without a source use the `trigger`
target. A missing or non-popover panel logs one configuration error and leaves the methods inert.

## Events

Events are dispatched from the panel:

| Event                 | Cancellable | Detail       |
| --------------------- | ----------- | ------------ |
| `popover:before-open` | yes         | `{ source }` |
| `popover:opened`      | no          | `{ source }` |
| `popover:closed`      | no          | `{ source }` |

`source` is the native invoker, or `null` for an external `showPopover()` call. `popover="manual"` panels get
no light dismissal; the consuming component provides every close path.

## popover-fetch

Loads a region inside the panel through the [fragment loader](../plumber/fragment_loader.md) when the
panel opens. No Turbo dependency; Turbo apps put a lazy Turbo Frame in the panel instead.

```html
<div
  data-controller="popover popover-fetch"
  data-popover-fetch-src-value="/menu"
  data-action="popover:opened->popover-fetch#onOpened popover:closed->popover-fetch#onClosed"
>
  <button data-popover-target="trigger" popovertarget="account-actions">Account</button>
  <div
    id="account-actions"
    data-popover-target="panel"
    popover="auto"
    role="region"
    aria-label="Account actions"
    tabindex="-1"
  >
    <div id="account_menu" data-popover-fetch-target="region"></div>
    <div role="status" data-popover-fetch-target="status"></div>
  </div>
</div>
```

The endpoint responds with an element of the region's `id`.

| Target   | Description                                                  |
| -------- | ------------------------------------------------------------ |
| `region` | Element replaced by the response; inside the panel, not it   |
| `status` | Optional; shows the loading and error text, outside `region` |

| Value         | Type    | Default                       | Description                                       |
| ------------- | ------- | ----------------------------- | ------------------------------------------------- |
| `src`         | String  | —                             | Region URL                                        |
| `reload`      | Boolean | `false`                       | Loads on every open instead of the first          |
| `loadingText` | String  | `Loading…`                    | Status while loading                              |
| `errorText`   | String  | `Content could not be loaded` | Status after a failed load; the next open retries |

| Action            | Wired on                 | Description                                                                   |
| ----------------- | ------------------------ | ----------------------------------------------------------------------------- |
| `onOpened(event)` | `popover:opened` on root | Loads the region; restores focus the swap drops ([ARIA.md](../../../ARIA.md)) |
| `onClosed(event)` | `popover:closed` on root | Cancels a load in flight                                                      |

Events from popovers inside the region are ignored.

## Accessibility

- See [ARIA.md's Popover pattern](../../../ARIA.md) for the accessibility contract.
