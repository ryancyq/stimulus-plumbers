# input-code

Draws a code input's characters, caret, and selection in cells, one character per cell. Pair it with [`input-formatter`](input-formatter.md) using the `"code"` formatter, which filters and caps the value.

## Targets

| Target  | Element   | Description                                                                                       |
| ------- | --------- | ------------------------------------------------------------------------------------------------- |
| `input` | `<input>` | The code input, laid over the cells with `opacity: 0`                                             |
| `cell`  | any       | One per character, in order; the controller sets `aria-hidden="true"` and draws the value into it |

## Methods

| Method   | Wired via                                                                                       | Description                                                  |
| -------- | ----------------------------------------------------------------------------------------------- | ------------------------------------------------------------ |
| `draw()` | `input-formatter:formatted`; `focus`, `blur`, `select`, `selectionchange`, `keyup` on the input | Draws the input's value, caret, and selection into the cells |

## Cell state attributes

| Attribute       | When                                                                        |
| --------------- | --------------------------------------------------------------------------- |
| `data-filled`   | The cell holds a character                                                  |
| `data-caret`    | The input has focus, nothing is selected, and the caret is before this cell |
| `data-selected` | The input has focus and its selection covers this cell                      |

A cell that ends a group can carry `data-group-end` in the markup, for a gap after it.

## Example

```html
<div
  data-controller="input-formatter input-code"
  data-input-formatter-format-value="code"
  data-input-formatter-options-value='{"charset":"digits","length":6}'
  data-action="input-formatter:formatted->input-code#draw"
>
  <label for="otp" class="sr-only">Verification code</label>
  <div class="cells-row">
    <span data-input-code-target="cell"></span>
    <span data-input-code-target="cell"></span>
    <span data-input-code-target="cell" data-group-end></span>
    <span data-input-code-target="cell"></span>
    <span data-input-code-target="cell"></span>
    <span data-input-code-target="cell"></span>
  </div>
  <input
    id="otp"
    autocomplete="one-time-code"
    inputmode="numeric"
    data-input-formatter-target="input"
    data-input-code-target="input"
    data-action="input->input-formatter#onInput form:reset->input-formatter#onFormReset focus->input-code#draw blur->input-code#draw select->input-code#draw selectionchange->input-code#draw keyup->input-code#draw"
  />
</div>
```

## Accessibility

- See [ARIA.md's Code Input pattern](../../../ARIA.md).
