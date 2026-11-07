# Progress

Rails helpers for rendering the four standalone `progress` variants. The controller also has a `range` variant, which has no `sp_*` helper — it is a form control, reached through [`f.field(as: :range)`](form.md). See [stimulus-plumbers's docs/component/progress.md](../../../stimulus-plumbers/docs/component/progress.md) for the controller's Values/Targets/Methods/Dispatches.

## Helpers

### `sp_progress_bar`

```erb
<%= sp_progress_bar(value: 65, max: 100, aria: { label: "Upload progress" }) %>
```

| Option           | Default   | Description                                                                                                                  |
| ---------------- | --------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `value:`         | —         | Required. Current value                                                                                                      |
| `min:`           | `0`       | Range minimum                                                                                                                |
| `max:`           | `100`     | Range maximum                                                                                                                |
| `indeterminate:` | `false`   | Omits `aria-valuenow`; the indeterminate value drives the fixed fill                                                         |
| `format:`        | `nil`     | Renders an on-screen readout: `:percent` \| `:value` \| `:value_max`. Any other value raises `ArgumentError`                 |
| `readout:`       | `:inside` | Where that readout sits: `:inside` (over the track) \| `:outside` (beside it). Always validated; no effect without `format:` |
| `**html_options` | —         | Forwarded to the outer `<div role="progressbar">`                                                                            |

`format:` renders the readout server-side, so it is correct before the controller connects. The text and its `aria-valuetext` behaviour are the same as the controller's — see [Readout formats](../../../stimulus-plumbers/docs/component/progress.md#readout-formats). The theme is told whether a readout is present, so it can give the track room for the text.

```erb
<%= sp_progress_bar(value: 45, format: :percent, aria: { label: "Upload progress" }) %>
<%= sp_progress_bar(value: 45, format: :percent, readout: :outside, aria: { label: "Upload progress" }) %>
```

`:outside` puts a track element and the readout inside the container, since the track clips its overflow. Role, ARIA, and `data-controller` stay on the container in both.

Theme keys: `progress_bar_value` (inside), `progress_bar_value_outside` + `progress_bar_container` (outside). A theme without the latter two renders `:outside` unstyled, not broken.

The fill's geometry comes from the rendered `--sp-progress-percent`
([JS](../../../stimulus-plumbers/docs/component/progress.md#geometry)), so it paints
before the controller connects, with or without a theme. While `indeterminate:`,
a theme may layer motion on the fixed fill (Tailwind slides it).

### `sp_progress_segmented`

```erb
<%= sp_progress_segmented(value: 6, segments: 5, max: 10, aria: { label: "Password strength" }) %>
```

`format:` is not supported here (it raises `ArgumentError`) — there is no single track to center a readout over.

Splits the track into `segments:` equal slots and distributes the value across them (max 10 with `segments: 5` → each slot spans 2 units). Renders one `fill` target per slot, each with its `--sp-progress-index`.

| Option           | Default     | Description                                                                                            |
| ---------------- | ----------- | ------------------------------------------------------------------------------------------------------ |
| `value:`         | —           | Required. Current value                                                                                |
| `segments:`      | —           | Required. Positive Integer; anything else raises `ArgumentError`                                       |
| `min:`           | `0`         | Range minimum                                                                                          |
| `max:`           | `100`       | Range maximum                                                                                          |
| `mode:`          | `:discrete` | `:discrete` lights a whole slot once reached; `:continuous` partially fills the boundary slot          |
| `ramp:`          | `nil`       | `:strength` colors slots danger → warning → success by position (strength meter); `nil` = single color |
| `indeterminate:` | `false`     | Omits `aria-valuenow`; a single chunk relays across the slots, one at a time                           |
| `**html_options` | —           | Forwarded to the outer `<div role="progressbar">`                                                      |

### `sp_progress_ring`

```erb
<%= sp_progress_ring(value: 60, max: 100, aria: { label: "Storage used" }) %>
```

| Option           | Default | Description                                                                                   |
| ---------------- | ------- | --------------------------------------------------------------------------------------------- |
| `value:`         | —       | Required. Current value                                                                       |
| `min:`           | `0`     | Range minimum                                                                                 |
| `max:`           | `100`   | Range maximum                                                                                 |
| `indeterminate:` | `false` | Omits `aria-valuenow`; the indeterminate value drives the fixed fill                          |
| `size:`          | `nil`   | `:sm` \| `:md` \| `:lg` size token; `nil` uses the icon's own size (override with `classes:`) |
| `**html_options` | —       | Forwarded to the rendered icon (role, aria, classes, etc.)                                    |

Renders via the theme's icon registry (icon name `"progress-ring"`), the same mechanism as `sp_icon`. Resize with the `size:` token (`:sm`/`:md`/`:lg`) or, for an exact size, a `classes:`/`class:` override (e.g. `classes: "size-16"`) — there is no radius option. **Themes must register a `"progress-ring"` icon to render the ring's visual structure** — `stimulus-plumbers-tailwind` ships one; a theme without it (including the unstyled `Themes::Base`) falls back to an empty `<span role="progressbar">` with no visible ring, same as `sp_icon` for an unknown icon name.

The theme's fill circle must carry `pathLength="100"`, so its dash follows the
rendered `--sp-progress-percent`. While `indeterminate:`, the arc is fixed; a theme
may spin it (Tailwind's `animate-spin`).

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
