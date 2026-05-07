# popover

Shows and hides content with optional remote loading. Backed by the `Visibility` and `ContentLoader` plumbers.

## Targets

| Target      | Description                                                            |
| ----------- | ---------------------------------------------------------------------- |
| `content`   | The element to show/hide                                               |
| `template`  | Optional `<template>` or element whose HTML is used as initial content |
| `loader`    | Optional element shown during remote load                              |
| `activator` | Optional element that tracks expanded state (`aria-expanded`)          |

## Values

| Value        | Type   | Default   | Description                                          |
| ------------ | ------ | --------- | ---------------------------------------------------- |
| `url`        | String | —         | Remote URL to fetch content from                     |
| `reload`     | String | `"never"` | When to reload: `"never"` \| `"always"` \| `"stale"` |
| `staleAfter` | Number | `3600`    | Seconds after which content is considered stale      |
| `loadedAt`   | String | —         | ISO timestamp of last load (set automatically)       |

## Methods

| Method                       | Wired via             | Description                                                                                                  |
| ---------------------------- | --------------------- | ------------------------------------------------------------------------------------------------------------ |
| `show()`                     | `data-action`         | Action — shows the content                                                                                   |
| `hide()`                     | `data-action`         | Action — hides the content                                                                                   |
| `shown()`                    | Visibility plumber    | Plumber callback — triggers `load()` after the element becomes visible                                       |
| `canLoad()`                  | ContentLoader plumber | Plumber callback (gate) — returns `false` for `<turbo-frame>` targets (sets `src` instead); `true` otherwise |
| `contentLoading()`           | ContentLoader plumber | Plumber callback — shows the `loader` target while fetching                                                  |
| `contentLoaded({ content })` | ContentLoader plumber | Plumber callback — inserts fetched content into `content` target, hides `loader`                             |
| `contentLoader()`            | ContentLoader plumber | Plumber callback — returns static content from `template` target (if no URL)                                 |

## Examples

### Static popover

```html
<div data-controller="popover">
  <button
    data-action="click->popover#show"
    data-popover-target="activator"
    aria-expanded="false"
    aria-haspopup="dialog"
  >
    Open
  </button>

  <div data-popover-target="content" hidden role="dialog" aria-label="Options">
    <p>Popover content</p>
    <button data-action="click->popover#hide">Close</button>
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
  <button data-action="click->popover#show">Help</button>

  <div data-popover-target="content" hidden>
    <div data-popover-target="loader" hidden>Loading…</div>
    <div data-popover-target="template"></div>
  </div>
</div>
```

### Turbo Frame (lazy load)

When `content` target is a `<turbo-frame>`, `canLoad()` sets its `src` attribute on show rather than fetching HTML directly.

```html
<div data-controller="popover" data-popover-url-value="/preview/123">
  <button data-action="click->popover#show">Preview</button>
  <turbo-frame data-popover-target="content" hidden></turbo-frame>
</div>
```

## Accessibility

- Trigger should have `aria-haspopup` describing the popup type and `aria-expanded` toggled by the `activator` target
- Content element should have an appropriate `role` (`dialog`, `tooltip`, `listbox`, etc.)
