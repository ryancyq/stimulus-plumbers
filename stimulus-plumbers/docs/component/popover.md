# popover

Adapts a native `popover` element to the popover lifecycle through the [popover plumber](../plumber/popover.md).
The browser owns the top layer, light dismissal, and Escape for `popover="auto"`; the consuming component owns
role, keyboard behavior, focus, and selection.

## Migration from legacy popover markup

The legacy controller toggled a `hidden` panel and could fetch its content:

```html
<div data-controller="popover" data-popover-url-value="/menu">
  <button data-popover-target="trigger" data-action="popover#toggle">Account</button>
  <div data-popover-target="panel" hidden></div>
</div>
```

Use a native popover panel; put remote content in a Turbo Frame inside it:

```html
<div data-controller="popover">
  <button data-popover-target="trigger" popovertarget="account-actions">Account</button>
  <div id="account-actions" data-popover-target="panel" popover="auto" role="region" aria-label="Account actions">
    <turbo-frame id="account_actions" src="/menu" loading="lazy"></turbo-frame>
  </div>
</div>
```

Remove the `url`, `loadedAt`, `reload`, `staleAfter`, `closeOnSelect`, `announceOpen`, and `announceClose`
values and any `controller.visibility`, `shift()`, or `flip()` dependencies. Combobox close-on-select moved to
[`input-combobox`](combobox.md#input-combobox).

## Targets

| Target    | Required | Description                                                     |
| --------- | -------- | --------------------------------------------------------------- |
| `trigger` | no       | Default source for programmatic opens                           |
| `panel`   | yes      | Native popover element (`popover="auto"` or `popover="manual"`) |

## Methods

| Method           | Description                                                       |
| ---------------- | ----------------------------------------------------------------- |
| `open(event?)`   | Opens the panel; an action event's current target is the source   |
| `close(event?)`  | Closes the panel                                                  |
| `toggle(event?)` | Toggles the panel; an action event's current target is the source |

The packaged button opens declaratively with `popovertarget` and needs no action. A custom source wires its own,
e.g. `click->popover#open` on an input. Light dismissal treats a custom source as outside the panel, so with
`popover="auto"` it can open the panel but not toggle it closed. Direct calls use the `trigger` target as the
source. A missing or non-popover panel logs one configuration error and leaves the methods inert.

## Events

Events are dispatched from the panel:

| Event                 | Cancellable | Detail       |
| --------------------- | ----------- | ------------ |
| `popover:before-open` | yes         | `{ source }` |
| `popover:opened`      | no          | `{ source }` |
| `popover:closed`      | no          | `{ source }` |

`source` is the native invoker, or `null` for an external `showPopover()` call. `popover="manual"` panels get
no light dismissal; the consuming component provides every close path.

## Accessibility

- See [ARIA.md's Popover pattern](../../../ARIA.md) for the accessibility contract.
