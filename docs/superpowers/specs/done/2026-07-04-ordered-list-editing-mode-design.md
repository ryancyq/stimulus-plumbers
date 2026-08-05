# OrderedList + `reorderable` editing mode design

## Scope

Two coupled pieces of work:

1. **`reorderable` JS controller/plumber** (`stimulus-plumbers/src/controllers/reorderable_controller.js`, `stimulus-plumbers/src/plumbers/reorderable.js`) — adds an `editingValue` Boolean, a `trigger` target, and gating so drag/keyboard-move only act while editing, leaving any `<a>`/`<button>` inside a reorderable item free to function normally outside editing mode.
2. **`OrderedList` Rails component** (`stimulus-plumbers-rails`) — new top-level component, sibling to `List`, the first real consumer of `reorderable`. Flat-only, always wired for reorder, item order is semantic content (`<ol>`, not `<ul>`).

Both are in scope for one implementation plan since `OrderedList`'s `handle:` design directly depends on editing-mode gating existing — building `OrderedList` first without it would require the (now superseded) `handle: :item` + `url:` validation guard.

No change to `List`/`List::Item` — this design does not touch them. No Tailwind theme classes for the new `ordered_list*` keys — components render via the `Base` theme's no-op defaults; visual styling is a separate follow-up task in `stimulus-plumbers-tailwind`.

## Part 1: `reorderable` editing mode (JS)

### Problem

A reorderable item's content may include a real `<a href>`/`<button>`. Without a mode boundary, any drag handle on the same item risks a press-and-release-without-movement misfiring that link/button's native click mid-interaction — this applies to any handle placement, not just a specific one.

### Design

- **New value:** `editingValue` (Boolean, default `false`) on the `reorderable` controller. Not specific to `OrderedList` — it lives on the controller itself, so any `reorderable` consumer gets it.
- **New target:** `trigger` — the inner `<a>`/`<button>` per item, when present. Content-only items simply have no `trigger` target.
- **Gating (no dynamic listener attach/detach):** listeners stay attached for the controller's lifetime; each handler no-ops when not editing, rather than being added/removed on toggle.
  - `Reorderable#onKeydown` (in `plumbers/reorderable.js`): first line becomes `if (!this.controller.editingValue) return;` — the plumber already holds `this.controller` via the base `Plumber` class, so no new option/callback plumbing is needed.
  - `ReorderableController#onPointerDown`/`onPointerMove`/`onPointerUp`: same one-line guard at the top of each.
  - `RovingTabIndex` (plain Arrow/Home/End focus movement) is **not** gated — focus movement is non-destructive and works identically regardless of editing state.
- **`editingValueChanged(value)` callback:** iterates `this.triggerTargets`, calls the existing `setDisabled(element, value)` helper (`src/accessibility/aria.js`) on each — sets `aria-disabled` and toggles `tabindex="-1"`, neutralizing keyboard activation (Enter/Space) and removing the trigger from tab order while editing.
- **Pointer-click neutralization is CSS, not JS:** Stimulus automatically reflects the value as `data-reorderable-editing-value="true"` on the controller element. The Tailwind theme (follow-up task, not this spec) adds `[data-reorderable-editing-value="true"] [data-reorderable-target="trigger"] { pointer-events: none }`. `Reorderable` does not intercept click events on the trigger itself — this keeps the plumber content-agnostic (it already doesn't know about link/button internals anywhere else).
- **Toggle actions:** `toggleEditing()`, plus explicit `enterEditing()`/`exitEditing()` for apps wanting separate Edit/Done buttons instead of one toggle. None of these render their own UI — matches `Timeline`'s precedent of documenting an action name (`timeline#toggle`) for the app to wire its own trigger, rather than the component rendering interaction chrome for itself.
- **This removes the need for a `handle: :item` + `url:` validation guard** in `OrderedList` (Part 2) — the link is only genuinely clickable while not editing, and dragging is only possible while editing, so they're mutually exclusive by construction for any `handle:` value.

### Testing (JS)

- `tests/unit/plumbers/reorderable.test.js`: `onKeydown` no-ops when `controller.editingValue` is falsy; still handles `Alt+Arrow` when truthy.
- `tests/unit/controllers/reorderable_controller.test.js`: `onPointerDown`/`onPointerMove`/`onPointerUp` no-op while not editing; `editingValueChanged` calls `setDisabled()` on every `triggerTarget`; `toggleEditing`/`enterEditing`/`exitEditing` flip `editingValue` and the reflected `data-reorderable-editing-value` attribute.

### Docs (JS)

`stimulus-plumbers/docs/component/reorderable.md` and `docs/plumber/reorderable.md` gain the `editingValue` value, `trigger` target, and `toggleEditing`/`enterEditing`/`exitEditing` actions — this is the only place they're documented, per the no-cross-doc-duplication rule.

## Part 2: `OrderedList` Rails component

### Files

- `lib/stimulus_plumbers/components/ordered_list.rb` — `sp_ordered_list` renderer. `render` → `<ol data-controller="reorderable" data-reorderable-move-key-value="..." data-reorderable-editing-value="...">`. `item(...)` delegates to `OrderedList::Item`. No `section` method — sections are structurally impossible on this component, not runtime-guarded.
- `lib/stimulus_plumbers/components/ordered_list/item.rb` — duplicates `List::Item`'s icon/title/description rendering logic (explicit choice: no shared mixin with `List::Item`, to avoid destabilizing it; accepted trade-off is future drift risk between the two).
- `lib/stimulus_plumbers/components/ordered_list/item/slots.rb` — same slot shape as `List::Item::Slots`: `icon_leading`, `title`, `description`, `icon_trailing`.
- `lib/stimulus_plumbers/helpers/ordered_list_helper.rb` — `sp_ordered_list`.

### `sp_ordered_list` options

| Option | Default | Description |
| --- | --- | --- |
| `move_key:` | `"Alt"` | Maps to `data-reorderable-move-key-value`. One of `Alt`, `Control`, `Shift`, `Meta`. |
| `editing:` | `false` | Initial render-time state, maps to `data-reorderable-editing-value`. |
| `**html_options` | — | Forwarded to the outer `<ol>`. |

### `list.item` options (on `OrderedList`, not `List`)

| Option | Default | Description |
| --- | --- | --- |
| `content` | `nil` | Item label — positional arg or via slot setters, same as `List::Item`. |
| `id:` | — | **Required.** Raises `ArgumentError` if missing — `Reorderable#orderedIds()` silently drops items without an `id` from the dispatched event's `itemIds`, and this component fails loud instead of letting that happen silently downstream. |
| `handle:` | `:item` | `:item` \| `:leading` \| `:trailing`. See below. |
| `url:` | `nil` | Same as `List::Item` — renders `<a href>` instead of `<button>`. |
| `**html_options` | — | Forwarded to the inner `<a>`/`<button>`. |

### Item DOM structure (fixed shape, independent of `handle:`)

```html
<li data-reorderable-target="item" id="row-1">
  <span data-reorderable-target="handle" data-action="pointerdown->reorderable#onPointerDown ...">
    <!-- icon_leading if set, else a default grip glyph, when handle: :leading -->
    <!-- otherwise: icon_leading as a plain decorative icon, if set -->
  </span>
  <a href="..." data-reorderable-target="trigger">
    <span>title</span>
    <span>description</span>
  </a>
  <span data-reorderable-target="handle" data-action="pointerdown->reorderable#onPointerDown ...">
    <!-- same logic as leading, mirrored for handle: :trailing -->
  </span>
</li>
```

- Icon positions (`icon_leading`/`icon_trailing`) are **always** siblings of the `<a>`/`<button>`, never nested inside it — this is the structural fix that motivated splitting `OrderedList` out of `List` in the first place, and it's unconditional, not dependent on which position is the handle.
- `data-reorderable-target="trigger"` is added to the `<a>`/`<button>` only when the item has one — content-only items omit it entirely (nothing for `editingValueChanged` to neutralize).
- `handle: :item` (default): `data-reorderable-target="handle"` plus the pointer `data-action`s go on the `<li data-reorderable-target="item">` element itself — same DOM node serves double duty. The JS plumber's `startDrag(item, handle, pointerId)` never required `item` and `handle` to be different elements, so this is a legitimate mode, not a workaround.
- `handle: :leading`/`:trailing`: that position's `<span>` gets the handle wiring instead of the `<li>`. If the corresponding icon slot is set, that custom icon is the drag surface; if not, a default grip glyph renders via `Icon.render(name: "grip-vertical")`. No `grip-vertical` icon or alias exists anywhere in this codebase today (checked `stimulus-plumbers-tailwind/lib/stimulus_plumbers/themes/tailwind/icon.rb`) — `Icon#render` degrades gracefully to an empty `<span>` when a name doesn't resolve (see `components/icon.rb`), so this doesn't break rendering, but the actual glyph needs to be added to the Tailwind theme's icon set as part of the Tailwind follow-up task, not assumed to already exist.
- No `handle: false` — every item has a pointer surface; `Alt+Arrow` keyboard reorder is always available regardless of `handle:` choice (inherent to `reorderable`, not opt-in).

### Theme keys (new cluster in `schema.rb`, near `list:`)

| Key | Element |
| --- | --- |
| `ordered_list` | Outer `<ol>` |
| `ordered_list_item` | `<li>` |
| `ordered_list_item_handle` | Leading/trailing `<span>` (decorative-or-handle) |
| `ordered_list_item_content` | Content wrapper inside `<a>`/`<button>` |
| `ordered_list_item_title` | Title `<span>` |
| `ordered_list_item_description` | Description `<span>` |

### Dispatches

`reorderable:reordered` — unchanged from the JS plumber, `{ itemIds: string[] }`. No Rails-side event contract changes.

### Testing (Rails)

- `test/stimulus_plumbers/components/ordered_list_test.rb`, `ordered_list/item_test.rb` — HTML structure and ARIA assertions: icon positions always outside the `<a>`/`<button>`, `handle:` variants produce the right target placement, missing `id:` raises, `trigger` target present only when `url:`/button set.
- `test/accessibility/components/ordered_list_test.rb` — new sandbox view; `assert_accessible` for both editing and non-editing states (two separate assertions, matching this gem's existing convention for interactive-state coverage). This is the first real `reorderable` consumer, so the a11y/snapshot deferral agreed earlier ends here.

### Docs (Rails)

New `stimulus-plumbers-rails/docs/component/ordered_list.md` — documents `move_key:`/`editing:`/`handle:`/`id:` and the rendered HTML structure; links to `stimulus-plumbers/docs/component/reorderable.md` for the JS controller's values/targets/actions rather than repeating them (no-cross-doc-duplication rule). Add a row to `stimulus-plumbers-rails/README.md`'s Components table.

## Out of scope

- `List`/`List::Item` — untouched by this design.
- Sections/grouping on `OrderedList` — structurally impossible (no `section` method), not a v1 cut to revisit later.
- Cross-list drag (moving an item between two separate `OrderedList`s).
- Calendar-style time-grid drag-reschedule (a genuinely different problem: cross-container + value-mapped drop position, not list-position swap — its own future brainstorm).
- Persistence/AJAX — still the app's responsibility via listening for `reorderable:reordered`.
- Tailwind theme classes for the new `ordered_list*` keys, the `pointer-events: none` editing-state rule, and the `grip-vertical` icon glyph — separate follow-up task in `stimulus-plumbers-tailwind`; components render (unstyled, with an empty `<span>` in place of the grip icon) without it.
