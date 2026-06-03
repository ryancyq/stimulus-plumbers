# dismisser

Closes/hides an element when the user clicks outside it. Backed by the `Dismisser` plumber.

## Targets

| Target    | Description                                                                                                                                                   |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `trigger` | Optional — passed as `{ target }` context to the `dismissed()` callback. Does not change the click-outside boundary (which is always the controller element). |

## Methods

| Method        | Wired via         | Description                                                                                          |
| ------------- | ----------------- | ---------------------------------------------------------------------------------------------------- |
| `dismissed()` | Dismisser plumber | Plumber callback — called when a click-outside is detected. Implement in your controller to respond. |

## Example

```html
<div data-controller="dismisser">
  <div data-dismisser-target="trigger">
    <p>Click outside this box to dismiss it.</p>
  </div>
</div>
```

Implement `dismissed()` on your controller to act on the dismissal:

```javascript
async dismissed() {
  await this.collapse()
}
```

## Notes

- The Dismisser plumber attaches a document-level `mousedown` listener. When a click lands outside the **controller element**, it calls `dismissed()`. If a `trigger` target is present, it is passed to `dismissed()` as `{ target }` context — it does not change the boundary.
- Used internally by `modal` (custom overlay mode) and `form-field` to handle click-outside-to-close.
- `dismissed()` is not called when clicking on the trigger element itself.
