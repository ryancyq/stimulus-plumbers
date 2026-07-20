# input-revealable

Reveals or conceals an obscured `<input>` by switching its `type` between `"password"` and `"text"`.

## Targets

| Target        | Element    | Description                                                     |
| ------------- | ---------- | --------------------------------------------------------------- |
| `input`       | `<input>`  | Obscured input; markup must initially declare `type="password"` |
| `toggle`      | `<button>` | Reveal/conceal button                                           |
| `revealIcon`  | `<svg>`    | Icon shown while the next action is reveal                      |
| `concealIcon` | `<svg>`    | Icon shown while the next action is conceal                     |

Supply both icons or neither — a lone icon stays visible and only the `aria-label` swaps.

## Values

| Value          | Type    | Default | Description                                   |
| -------------- | ------- | ------- | --------------------------------------------- |
| `revealed`     | Boolean | `false` | Whether the input is revealed                 |
| `revealLabel`  | String  | `""`    | Toggle label while the next action is reveal  |
| `concealLabel` | String  | `""`    | Toggle label while the next action is conceal |

## Methods

| Method     | Wired via     | Description           |
| ---------- | ------------- | --------------------- |
| `toggle()` | `data-action` | Flips `revealedValue` |

## Readonly secret

```html
<div
  data-controller="input-revealable"
  data-input-revealable-reveal-label-value="Show API key"
  data-input-revealable-conceal-label-value="Hide API key"
>
  <input
    type="password"
    readonly
    value="sk_live_example"
    autocomplete="off"
    data-1p-ignore
    data-lpignore="true"
    data-input-revealable-target="input"
  />
  <button
    type="button"
    aria-label="Show API key"
    data-input-revealable-target="toggle"
    data-action="click->input-revealable#toggle"
  >
    <svg data-input-revealable-target="revealIcon" aria-hidden="true"></svg>
    <svg data-input-revealable-target="concealIcon" aria-hidden="true" hidden></svg>
  </button>
</div>
```

`type="password"` triggers password-manager heuristics. Suppress them in your own markup with `autocomplete="off"`, `data-1p-ignore`, and `data-lpignore="true"` — the controller does not set these.

Non-input elements (`<output>`, `<span>`, table cells) are unsupported. Server-render both states and swap them with `setHidden`.

## Accessibility

See [ARIA.md's Password Reveal pattern](../../../ARIA.md) for the toggle button's accessible-name requirements.
