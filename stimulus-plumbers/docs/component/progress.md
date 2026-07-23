# Progress

Value-driven progress indicator supporting four render variants: a linear bar, a segmented bar, an SVG ring, and a native `<meter>`.

## Stimulus Identifier

`progress`

## Targets

| Name    | Element                           | Purpose                                                                                                                                                                             |
| ------- | --------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `fill`  | `<div>` (bar) / `<circle>` (ring) | Element whose `width` (bar) or `stroke-dasharray`/`stroke-dashoffset` (ring) is set. Segmented renders **one `fill` per segment**; the controller distributes the value across them |
| `meter` | `<meter>`                         | Present only for `variant: "meter"` — native element, attributes synced directly                                                                                                    |

## Values

| Name                    | Type    | Default      | Purpose                                                                                                                                |
| ----------------------- | ------- | ------------ | -------------------------------------------------------------------------------------------------------------------------------------- |
| `variant`               | String  | `"bar"`      | `"bar"` \| `"segmented"` \| `"ring"` \| `"meter"`                                                                                      |
| `current`               | Number  | `0`          | Current value                                                                                                                          |
| `min`                   | Number  | `0`          | Range minimum                                                                                                                          |
| `max`                   | Number  | `100`        | Range maximum                                                                                                                          |
| `optimum`               | Number  | —            | Meter-only; maps to native `<meter optimum>`                                                                                           |
| `low`                   | Number  | —            | Meter-only; maps to native `<meter low>`                                                                                               |
| `high`                  | Number  | —            | Meter-only; maps to native `<meter high>`                                                                                              |
| `indeterminate`         | Boolean | `false`      | Suppresses `aria-valuenow`; toggles the `sp-progress-indeterminate` class                                                              |
| `indeterminateFraction` | Number  | `0.25`       | Bar width / ring arc / segment chunk-width fraction rendered while indeterminate                                                       |
| `segmentMode`           | String  | `"discrete"` | Segmented-only. `"discrete"` lights a whole segment once progress reaches into it; `"continuous"` partially fills the boundary segment |

## Methods

| Method                       | Wired via               | Purpose                                                                                                   |
| ---------------------------- | ----------------------- | --------------------------------------------------------------------------------------------------------- |
| `setValue(value)`            | —                       | Programmatic API — clamps to `[min, max]`, updates `currentValue`, dispatches `progress:changed`          |
| `currentValueChanged(value)` | Stimulus value callback | Recalculates fill/meter attrs whenever `current` changes (covers `setValue()` and direct attribute edits) |

## Dispatches

| Event              | Detail                | When                                 |
| ------------------ | --------------------- | ------------------------------------ |
| `progress:changed` | `{ value, min, max }` | After `setValue()` updates the value |

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

<!-- Indeterminate -->
<div role="progressbar" data-controller="progress" data-progress-indeterminate-value="true">
  <div data-progress-target="fill"></div>
</div>
```
