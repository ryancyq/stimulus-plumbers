# Done — Completed Design Decisions

---

## 1. Plumber Architecture

### `renders` macro (`Plumber::Renderer`)

`renders :name, with:, slots:, by:` generates four method families per slot:

| Method | Role |
|---|---|
| `with_#{name}(value / &block)` | Setter — stores value, proc, or a `Slots` builder |
| `#{name}` | Getter |
| `#{name}?` | Predicate — delegates to `slot_renderable?` |
| `render_#{name}` | Renderer — dispatches through `Dispatcher.build` |

`render_#{name}` is guarded by `slot_renderable?` — returns `nil` if the slot was never set.

### Dispatcher choice

| `with:` value | Dispatcher | Component accessible? |
|---|---|---|
| `:symbol` | `MethodCall` | yes — runs on `self` |
| `proc` / block | `InstanceExec` | yes — `self` = component |
| `Class` / String | `KlassProxy` | no — instantiated with `(template)`, calls `render` |

### `Plumber::Slots` — class-level DSL

```ruby
class Plumber::Slots
  def self.slot(*names, by: nil)  # generates with_#{name}, #{name}, #{name}?
  def resolve(name, &transform)   # block wins if proc; transform applied to string values
  def options_for(name)           # per-slot extra options (e.g. url:)
  def any? / none?                # used by slot_renderable? to short-circuit rendering
end
```

Setter methods use `with_*` prefix. The `method_missing`-based approach was not implemented.

### `Plumber::Renderer` — extension point, not for built-ins

Built-in components do **not** call `renders`. They use:

**Pattern A** — `Plumber::Slots.new` per render call (Button, Link, Card, List::Item):
```ruby
slots = Button::Slots.new
slots.with_icon_leading(icon_leading) if icon_leading
# resolved inline by private methods on the same component
```

**Pattern B** — `template.capture(self, &block)` (List, Button::Group, Popover):
```ruby
template.content_tag(:ul, template.capture(self, &block), **html_options)
```

`Plumber::Renderer` (`renders` macro) is the extension point for **custom component authors** who design their API around `with_*` setters from the start and compose `Plumber::Base` sub-components initialized with `(template)` only. Built-in components use Pattern A / B — adopting `Renderer` everywhere would require breaking API changes with no benefit.

Key reasons built-ins don't use `renders`:
- `@set_slots` persists across calls; `Slots.new` per render is intentionally stateless
- `render_icon_slot(slots, name, theme_key:)` signature doesn't match `slot_kwargs_for`
- Per-slot `url:` option (Card action) is not forwarded by `slot_kwargs_for`
- Pattern B uses `capture(self, &block)` — no slot-setting phase to intercept

`@set_slots` (from `Renderer`) is lazy via `||=`. Components with no `with_*` calls never allocate it.

---

## 2. Card + List Refactor

`ActionList` renamed to `List` (`sp_list`). Both Card and List::Item now use `Plumber::Slots`.

### Architecture

| Component | Pattern | Notes |
|---|---|---|
| `Card` | `Card::Slots < Plumber::Slots` slot accumulation | block yields slots object |
| `List` | direct-render builder (`template.capture(self)`) | — |
| `List::Section` | keyword params `title:`, `description:` | — |
| `List::Item` | `Item::Slots` slot accumulation | fast path: positional string |

**`Plumber::SlotRegistration` was not created.** Both `Card::Slots` and `List::Item::Slots` subclass `Plumber::Slots` directly.

### Card API

```erb
<%= sp_card(variant: :primary, title_tag: :h3) do |card| %>
  <% card.with_icon("user") %>
  <% card.with_title("Account") %>
  <% card.with_body { "Your account is active." } %>
  <% card.with_action("Manage", url: "/settings") %>
<% end %>
```

- `with_action(url:)` with no string and no block raises `ArgumentError`
- `with_body` accepts a string (wrapped in `<p>`) or a block (rendered as-is)
- Render order: header wrapper (icon + title) → body → action

### List API

```erb
<%# Flat mode %>
<%= sp_list do |list| %>
  <%= list.item("Dashboard", url: "/") do |item| %>
    <% item.with_icon_leading("home") %>
    <% item.with_icon_trailing("chevron-right") %>
  <% end %>
<% end %>

<%# Grouped mode %>
<%= sp_list(heading_level: 2) do |list| %>
  <%= list.section(title: "Workspace") do |section| %>
    <%= section.item("Dashboard", url: "/") %>
  <% end %>
<% end %>
```

`List::Item` sub-slots: `with_icon_leading`, `with_title`, `with_description`, `with_icon_trailing`. Fast path: `list.item("Label")` pre-populates `with_title`; block `item.with_title(...)` overwrites.

`List::Section` heading behavior: no `heading_level` → title renders as `<span aria-hidden="true">`; with `heading_level` → renders as `<h{n}>`. Nested sections increment and clamp at `h6`.

---

## 3. Bug and Doc Fixes

**P1 — Sandbox routing ✅** — Updated `components_controller.rb` (`action_list` → `list`), `popover.html.erb` (`sp_action_list` → `sp_list`), `profile.html.erb` (rewrote using `sp_card` slot DSL and `sp_list`).

**P4 — CLAUDE.md folder tree ✅** — Updated tree shows `list.rb`, `card/slots.rb`, correct `plumber/` entries. Stale `action_list.*` and `card/section.rb` entries removed.

**`assert_valid_heading_order` ✅** — Undefined method in `action_list_accessibility_test.rb` resolved (test removed or method defined).
