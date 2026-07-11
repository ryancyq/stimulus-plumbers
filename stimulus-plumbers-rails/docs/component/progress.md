# Progress

Rails helpers for rendering the `progress` Stimulus controller's three variants. See [stimulus-plumbers's docs/component/progress.md](../../../stimulus-plumbers/docs/component/progress.md) for the controller's Values/Targets/Methods/Dispatches.

## Helpers

### `sp_progress_bar`

```erb
<%= sp_progress_bar(value: 65, max: 100, aria: { label: "Upload progress" }) %>
```

| Option           | Default | Description                                              |
| ---------------- | ------- | -------------------------------------------------------- |
| `value:`         | —       | Required. Current value                                  |
| `min:`           | `0`     | Range minimum                                            |
| `max:`           | `100`   | Range maximum                                            |
| `indeterminate:` | `false` | Omits `aria-valuenow`; adds the indeterminate hook class |
| `**html_options` | —       | Forwarded to the outer `<div role="progressbar">`        |

When `indeterminate:` is true, the JS controller sets a fixed 25% fill
width directly — this is the same with or without a theme. A theme may
layer motion on top (Tailwind slides it); without one, the bar renders
as a static partial fill.

### `sp_progress_ring`

```erb
<%= sp_progress_ring(value: 60, max: 100, aria: { label: "Storage used" }) %>
```

| Option           | Default | Description                                                |
| ---------------- | ------- | ---------------------------------------------------------- |
| `value:`         | —       | Required. Current value                                    |
| `min:`           | `0`     | Range minimum                                              |
| `max:`           | `100`   | Range maximum                                              |
| `indeterminate:` | `false` | Omits `aria-valuenow`; adds the indeterminate hook class   |
| `**html_options` | —       | Forwarded to the rendered icon (role, aria, classes, etc.) |

Renders via the theme's icon registry (icon name `"progress-ring"`), the same mechanism as `sp_icon`. Track/fill color and ring size are fixed by the icon's own SVG — resize with a `classes:`/`class:` override (e.g. `classes: "size-16"`) rather than a radius option. **Themes must register a `"progress-ring"` icon to render the ring's visual structure** — `stimulus-plumbers-tailwind` ships one; a theme without it (including the unstyled `Themes::Base`) falls back to an empty `<span role="progressbar">` with no visible ring, same as `sp_icon` for an unknown icon name.

When `indeterminate:` is true (and a theme provides the ring icon), the JS
controller sets the fill circle's `stroke-dasharray` to a fixed 25% arc
directly, same as the bar. A theme may spin it (Tailwind's `animate-spin`);
without one, the arc renders static.

### `sp_progress_meter`

```erb
<%= sp_progress_meter(value: 6, min: 0, max: 10, low: 3, high: 8, optimum: 9, aria: { label: "Disk usage" }) %>
```

| Option           | Default | Description                                       |
| ---------------- | ------- | ------------------------------------------------- |
| `value:`         | —       | Required. Current value                           |
| `min:`           | `0`     | Range minimum                                     |
| `max:`           | `100`   | Range maximum                                     |
| `low:`           | `nil`   | Native `<meter low>` — omitted when not given     |
| `high:`          | `nil`   | Native `<meter high>` — omitted when not given    |
| `optimum:`       | `nil`   | Native `<meter optimum>` — omitted when not given |
| `**html_options` | —       | Forwarded to the `<meter>`                        |

## Known limitation

`<meter>` styling relies on `::-webkit-meter-*`/`::-moz-meter-*` pseudo-elements — cross-browser visual consistency is limited; this is a native-element tradeoff, not a bug.
