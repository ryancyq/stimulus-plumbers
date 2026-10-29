# clipboard

Re-dispatches native paste events as cancelable Stimulus events. Also provides a copy action that writes text to the clipboard via the Clipboard API.

## Targets

| Target   | Description                                                                         |
| -------- | ----------------------------------------------------------------------------------- |
| `source` | Element whose `.value` or `.textContent` is copied when no `text` param is provided |

## Values

| Value         | Type   | Default        | Description                                                                                                      |
| ------------- | ------ | -------------- | ---------------------------------------------------------------------------------------------------------------- |
| `contentType` | String | `"text/plain"` | MIME type to extract from `clipboardData` on paste. Common: `"text/plain"` \| `"text/html"` \| `"text/uri-list"` |

## Methods

| Method           | Wired via         | Description                                                                                             |
| ---------------- | ----------------- | ------------------------------------------------------------------------------------------------------- |
| `onPaste(event)` | `paste` DOM event | Event adapter — dispatches `clipboard:pasted`; cancels the native paste only if that event is cancelled |
| `copy(event)`    | `data-action`     | Action — writes text to clipboard, dispatches `clipboard:copied`                                        |

## Dispatches

| Event                   | Detail            | When                                                         |
| ----------------------- | ----------------- | ------------------------------------------------------------ |
| `clipboard:pasted`      | `{ text, types }` | On paste; cancelable                                         |
| `clipboard:copied`      | `{ text }`        | On successful clipboard write                                |
| `clipboard:copy-failed` | `{ error }`       | On clipboard write failure, or when there is nothing to copy |

## Paste example

```html
<%# Intercept paste, forward to input-formatter for normalisation %>
<input
  data-controller="clipboard"
  data-action="paste->clipboard#onPaste clipboard:pasted->input-formatter#onPaste"
  data-clipboard-content-type-value="text/plain"
/>
```

## Copy examples

```html
<%# Copy from a source target %>
<div data-controller="clipboard">
  <input data-clipboard-target="source" value="text to copy" readonly />
  <button data-action="click->clipboard#copy">Copy</button>
</div>

<%# Copy hardcoded text via param %>
<button data-controller="clipboard" data-action="click->clipboard#copy" data-clipboard-text-param="https://example.com">
  Copy link
</button>
```

## Notes

- The native paste proceeds unless a `clipboard:pasted` listener calls `preventDefault()`
- Use `clipboard:pasted->input-formatter#onPaste` to forward pasted content for formatting
