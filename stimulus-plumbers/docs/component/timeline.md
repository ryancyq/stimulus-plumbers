# Timeline

Manages expandable/collapsible timeline event items with keyboard navigation and optional client-side date formatting.

## Stimulus Identifier

`timeline`

## Targets

| Name      | Element                       | Purpose                                            |
| --------- | ----------------------------- | -------------------------------------------------- |
| `trigger` | `<button>` inside each `<h3>` | Controls expand/collapse of its associated detail  |
| `detail`  | Collapsible region            | Content shown/hidden via `aria-controls` reference |

## Values

| Name         | Type   | Default | Purpose                                                                                                 |
| ------------ | ------ | ------- | ------------------------------------------------------------------------------------------------------- |
| `dateFormat` | Object | `{}`    | `Intl.DateTimeFormat` options applied to empty `<time datetime>` elements on connect. No-op when empty. |

## Actions

| Name       | Purpose                                     |
| ---------- | ------------------------------------------- |
| `toggle`   | Expands if collapsed, collapses if expanded |
| `expand`   | Expands the item                            |
| `collapse` | Collapses the item                          |

## Keyboard

| Key         | Behaviour                      |
| ----------- | ------------------------------ |
| `ArrowDown` | Focus next trigger (wraps)     |
| `ArrowUp`   | Focus previous trigger (wraps) |
| `Home`      | Focus first trigger            |
| `End`       | Focus last trigger             |

## Example HTML

```html
<!-- Static timeline with server-rendered date text -->
<ol data-controller="timeline">
  <li>
    <time datetime="2024-01-15">January 2024</time>
    <h3>Event title</h3>
  </li>
</ol>

<!-- Static timeline with client-side date formatting -->
<ol data-controller="timeline" data-timeline-date-format-value='{"month":"long","year":"numeric","day":"numeric"}'>
  <li>
    <time datetime="2024-01-15"></time>
    <h3>Event title</h3>
  </li>
</ol>

<!-- Interactive timeline with expandable details -->
<ol data-controller="timeline">
  <li>
    <h3>
      <button
        data-timeline-target="trigger"
        data-action="timeline#toggle"
        aria-expanded="false"
        aria-controls="detail-1"
      >
        Event title
      </button>
    </h3>
    <div id="detail-1" data-timeline-target="detail" hidden>Detail content</div>
  </li>
</ol>
```
