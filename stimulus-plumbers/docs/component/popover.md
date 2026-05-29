# popover

Shows and hides a panel with optional remote loading. Owns visibility, `aria-expanded`, outside-click dismissal, and focus management. Backed by the `Visibility`, `Dismisser`, and `ContentLoader` plumbers.

This controller is also the visibility/dismissal layer for the combobox family — `input-combobox` runs alongside it and delegates open/close to `popover` (see [combobox docs](./combobox.md)).

## Targets

| Target     | Description                                                                       |
| ---------- | --------------------------------------------------------------------------------- |
| `trigger`  | The activator element — opens/toggles the panel and tracks `aria-expanded`        |
| `panel`    | The element to show/hide (and load remote content into)                           |
| `template` | Optional `<template>` or element whose HTML is used as initial content            |
| `loader`   | Optional element shown during remote load                                         |

## Values

| Value           | Type    | Default   | Description                                          |
| --------------- | ------- | --------- | ---------------------------------------------------- |
| `url`           | String  | —         | Remote URL to fetch content from                     |
| `reload`        | String  | `"never"` | When to reload: `"never"` \| `"always"` \| `"stale"` |
| `staleAfter`    | Number  | `3600`    | Seconds after which content is considered stale      |
| `loadedAt`      | String  | —         | ISO timestamp of last load (set automatically)       |
| `closeOnSelect` | Boolean | `true`    | Whether a `#closeOnSelect` call dismisses the panel  |

## Methods

| Method                       | Wired via             | Description                                                                                                  |
| ---------------------------- | --------------------- | ------------------------------------------------------------------------------------------------------------ |
| `open()`                     | `data-action`         | Action — shows the panel                                                                                      |
| `close()`                    | `data-action`         | Action — hides the panel (used by Esc, close buttons, outside-click)                                         |
| `toggle()`                   | `data-action`         | Action — shows when hidden, hides when visible                                                                |
| `closeOnSelect()`            | `data-action`         | Action — hides the panel only when `closeOnSelect` value is `true`; used by selection events                 |
| `shown()`                    | Visibility plumber    | Plumber callback — triggers `load()`, then moves focus into the panel                                        |
| `hidden()`                   | Visibility plumber    | Plumber callback — returns focus to the `trigger`                                                            |
| `dismissed()`                | Dismisser plumber     | Plumber callback — closes the panel on outside click                                                        |
| `canLoad()`                  | ContentLoader plumber | Plumber callback (gate) — returns `false` for `<turbo-frame>` panels (sets `src` instead); `true` otherwise  |
| `contentLoading()`           | ContentLoader plumber | Plumber callback — shows the `loader` target while fetching                                                  |
| `contentLoaded({ content })` | ContentLoader plumber | Plumber callback — inserts fetched content into the `panel` target, hides `loader`                          |
| `contentLoader()`            | ContentLoader plumber | Plumber callback — returns static content from `template` target (if no URL)                                 |

## Examples

### Static popover

```html
<div data-controller="popover">
  <button
    data-action="click->popover#toggle keydown.esc->popover#close"
    data-popover-target="trigger"
    aria-haspopup="dialog"
    aria-expanded="false"
    aria-controls="opts"
  >
    Open
  </button>

  <div id="opts" data-popover-target="panel" hidden role="dialog" aria-label="Options">
    <p>Popover content</p>
    <button data-action="click->popover#close">Close</button>
  </div>
</div>
```

### Remote content (fetch on show)

```html
<div
  data-controller="popover"
  data-popover-url-value="/help/tooltip"
  data-popover-reload-value="stale"
  data-popover-stale-after-value="300"
>
  <button data-action="click->popover#toggle" data-popover-target="trigger">Help</button>

  <div data-popover-target="panel" hidden>
    <div data-popover-target="loader" hidden>Loading…</div>
    <div data-popover-target="template"></div>
  </div>
</div>
```

### Turbo Frame (lazy load)

When the `panel` target is a `<turbo-frame>`, `canLoad()` sets its `src` attribute on show rather than fetching HTML directly.

```html
<div data-controller="popover" data-popover-url-value="/preview/123">
  <button data-action="click->popover#toggle" data-popover-target="trigger">Preview</button>
  <turbo-frame data-popover-target="panel" hidden></turbo-frame>
</div>
```

### Keep panel open on select

Selection events (from combobox sub-controllers, menu items, etc.) can be wired to `closeOnSelect`. Set `data-popover-close-on-select-value="false"` to keep the panel open after a selection — useful for multi-step pickers (date ranges, multi-select).

```html
<div data-controller="popover" data-popover-close-on-select-value="false">
  ...
  <ul data-action="my-list:selected->popover#closeOnSelect">…</ul>
</div>
```

## Accessibility

- `trigger` should have `aria-haspopup` describing the popup type; `aria-expanded` is toggled automatically.
- `panel` should have an appropriate `role` (`dialog`, `tooltip`, `listbox`, etc.).
- Esc and outside-click both close the panel; focus returns to the `trigger` on close.
