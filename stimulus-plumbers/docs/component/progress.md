# Progress

Value-driven progress indicator supporting five render variants: a linear bar, a segmented bar, an SVG ring, a native `<meter>`, and a native `<input type="range">`.

## Stimulus Identifier

`progress`

## Targets

| Name    | Element                           | Purpose                                                                                                                                                                             |
| ------- | --------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `fill`  | `<div>` (bar) / `<circle>` (ring) | Element whose `width` (bar) or `stroke-dasharray`/`stroke-dashoffset` (ring) is set. Segmented renders **one `fill` per segment**; the controller distributes the value across them |
| `meter` | `<meter>`                         | Present only for `variant: "meter"` — native element, attributes synced directly                                                                                                    |
| `value` | `<span>`                          | Optional on-screen readout; its `textContent` is set from `format`. Bar and range variants                                                                                          |
| `input` | `<input type="range">`            | Range-only, and only when a readout is present — the controller then sits on a wrapper containing both                                                                              |

## Values

| Name                    | Type    | Default      | Purpose                                                                                                                                |
| ----------------------- | ------- | ------------ | -------------------------------------------------------------------------------------------------------------------------------------- |
| `variant`               | String  | `"bar"`      | `"bar"` \| `"segmented"` \| `"ring"` \| `"meter"` \| `"range"`                                                                         |
| `current`               | Number  | `0`          | Current value                                                                                                                          |
| `min`                   | Number  | `0`          | Range minimum                                                                                                                          |
| `max`                   | Number  | `100`        | Range maximum                                                                                                                          |
| `optimum`               | Number  | —            | Meter-only; maps to native `<meter optimum>`                                                                                           |
| `low`                   | Number  | —            | Meter-only; maps to native `<meter low>`                                                                                               |
| `high`                  | Number  | —            | Meter-only; maps to native `<meter high>`                                                                                              |
| `indeterminate`         | Boolean | `false`      | Suppresses `aria-valuenow`; toggles the `sp-progress-indeterminate` class                                                              |
| `indeterminateFraction` | Number  | `0.25`       | Bar width / ring arc / segment chunk-width fraction rendered while indeterminate                                                       |
| `segmentMode`           | String  | `"discrete"` | Segmented-only. `"discrete"` lights a whole segment once progress reaches into it; `"continuous"` partially fills the boundary segment |
| `format`                | String  | `""`         | Readout text for the `value` target: `"percent"` \| `"value"` \| `"value_max"`. Empty or unrecognized renders nothing                  |

### Readout formats

| `format`      | Renders   | `aria-valuetext` |
| ------------- | --------- | ---------------- |
| `"percent"`   | `45%`     | not set          |
| `"value"`     | `45`      | `45`             |
| `"value_max"` | `45 / 60` | `45 / 60`        |

`percent` omits `aria-valuetext` — assistive technology derives the percentage from `aria-valuenow` itself, so setting it would only duplicate what AT already announces. The readout element is decorative (`aria-hidden`); the value reaches AT through `aria-valuenow`/`aria-valuetext`.

The `range` variant writes no `aria-value*` at all — a native `<input type="range">` already exposes its own slider semantics — and sets `--sp-progress-percent` on the input so a theme can paint the filled portion of the track.

The rendered number is the value clamped to `[min, max]`, so an out-of-range `current` reads as the nearest bound rather than an impossible percentage. An empty or inverted range (`max <= min`) renders `0%`. While `indeterminate`, the readout is blank and `aria-valuetext` is removed.

## Methods

| Method                       | Wired via                 | Purpose                                                                                                   |
| ---------------------------- | ------------------------- | --------------------------------------------------------------------------------------------------------- |
| `setValue(value)`            | —                         | Programmatic API — clamps to `[min, max]`, updates `currentValue`, dispatches `progress:changed`          |
| `currentValueChanged(value)` | Stimulus value callback   | Recalculates fill/meter attrs whenever `current` changes (covers `setValue()` and direct attribute edits) |
| `refresh()`                  | `input->progress#refresh` | Range-only. Reads the native input's value and passes it to `setValue()`                                  |

## Dispatches

| Event              | Detail                | When                                                                                   |
| ------------------ | --------------------- | -------------------------------------------------------------------------------------- |
| `progress:changed` | `{ value, min, max }` | After `setValue()` updates the value — including a range drag, which routes through it |

## Example HTML

```html
<!-- Bar -->
<div
  role="progressbar"
  data-controller="progress"
  data-progress-current-value="30"
  data-progress-min-value="0"
  data-progress-max-value="100"
>
  <div data-progress-target="fill"></div>
</div>

<!-- Bar with an on-screen readout -->
<div
  role="progressbar"
  data-controller="progress"
  data-progress-current-value="45"
  data-progress-max-value="100"
  data-progress-format-value="percent"
>
  <div data-progress-target="fill"></div>
  <span data-progress-target="value" aria-hidden="true">45%</span>
</div>

<!-- Segmented — one fill per segment; number of segments = number of fill targets -->
<div
  role="progressbar"
  data-controller="progress"
  data-progress-variant-value="segmented"
  data-progress-current-value="6"
  data-progress-max-value="10"
>
  <!-- ×5 slots → segment size 2 -->
  <div aria-hidden="true"><div data-progress-target="fill"></div></div>
  <div aria-hidden="true"><div data-progress-target="fill"></div></div>
  <div aria-hidden="true"><div data-progress-target="fill"></div></div>
  <div aria-hidden="true"><div data-progress-target="fill"></div></div>
  <div aria-hidden="true"><div data-progress-target="fill"></div></div>
</div>

<!-- Ring -->
<svg
  role="progressbar"
  data-controller="progress"
  data-progress-variant-value="ring"
  data-progress-current-value="25"
  data-progress-max-value="100"
>
  <circle data-progress-target="fill" r="40"></circle>
</svg>

<!-- Meter -->
<meter
  data-controller="progress"
  data-progress-variant-value="meter"
  data-progress-target="meter"
  data-progress-current-value="40"
  data-progress-min-value="0"
  data-progress-max-value="100"
></meter>

<!-- Range — no readout, so the controller sits on the input itself -->
<input
  type="range"
  min="0"
  max="100"
  value="45"
  style="--sp-progress-percent: 45"
  data-controller="progress"
  data-progress-variant-value="range"
  data-progress-current-value="45"
  data-progress-min-value="0"
  data-progress-max-value="100"
  data-action="input->progress#refresh"
/>

<!-- Range with a readout — a target must be a descendant, so a wrapper hosts the controller -->
<div
  data-controller="progress"
  data-progress-variant-value="range"
  data-progress-current-value="45"
  data-progress-max-value="100"
  data-progress-format-value="percent"
  data-action="input->progress#refresh"
>
  <input type="range" min="0" max="100" value="45" style="--sp-progress-percent: 45" data-progress-target="input" />
  <span data-progress-target="value" aria-hidden="true">45%</span>
</div>

<!-- Indeterminate -->
<div role="progressbar" data-controller="progress" data-progress-indeterminate-value="true">
  <div data-progress-target="fill"></div>
</div>
```
