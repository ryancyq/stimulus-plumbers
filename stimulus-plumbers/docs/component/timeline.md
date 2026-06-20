# Timeline

Manages expandable/collapsible timeline event items with keyboard navigation. Each item has a trigger button that controls a collapsible detail region.

## Stimulus Identifier

`timeline`

## Targets

| Name | Element | Purpose |
|------|---------|---------|
| `trigger` | `<button>` inside each `<h3>` | Controls expand/collapse of its associated detail |
| `detail` | Collapsible region | Content shown/hidden via `aria-controls` reference |
| `item` | `<li>` wrapper | Groups a trigger and its detail |

## Values

| Name | Type | Default | Purpose |
|------|------|---------|---------|
| `orientation` | String | `"vertical"` | Layout orientation of the timeline |

## Actions

| Name | Purpose |
|------|---------|
| `toggle` | Expands if collapsed, collapses if expanded |
| `expand` | Expands the item |
| `collapse` | Collapses the item |

## Keyboard

| Key | Behaviour |
|-----|-----------|
| `ArrowDown` | Focus next trigger |
| `ArrowUp` | Focus previous trigger |
| `Home` | Focus first trigger |
| `End` | Focus last trigger |

## Example HTML

```html
<ol data-controller="timeline">
  <li data-timeline-target="item">
    <h3>
      <button data-timeline-target="trigger"
              data-action="timeline#toggle"
              aria-expanded="false"
              aria-controls="detail-1">
        Event title
      </button>
    </h3>
    <div id="detail-1" data-timeline-target="detail" hidden>
      Detail content
    </div>
  </li>
</ol>
```
