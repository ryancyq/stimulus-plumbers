# Combobox — Popover-first Redesign

> **Status: implemented**, with these deltas from the sketch below:
>
> - There is **no separate `Panel` class hierarchy**. Each variant renderer
>   (`Combobox::Dropdown/Typeahead/Date/Time`) carries a nested `Metadata` module
>   (`haspopup`, `popup_id_for`, `trigger_icon`, `trigger_options`, `stimulus_data(panel_id, options)`)
>   alongside its instance `render`. One file per variant.
> - `Combobox::Builder` (a `Plumber::Slots` subclass, single `:variant` slot) is the only
>   intermediary: `c.dropdown/typeahead/date/time` record `(renderer, options)`; it exposes
>   `#metadata` (the variant's `Metadata`, or `DefaultMetadata` when none is selected) and
>   `#render_panel`. `Combobox#render` reads wiring off `metadata` and the body off the builder.
> - `Metadata.stimulus_data` takes `options` so the time picker can emit its `options` JSON; the same
>   method supplies the date/time `format` value and the typeahead outlet wiring.
> - The hidden input keeps `name:` (form builder needs it).
> - `Combobox#render` keeps the structured `trigger:`/`input:` kwargs for the form layer;
>   only the variant/`haspopup`/`popup_id`/explicit panel block were replaced by the builder.
> - `c.custom` (arbitrary panel) is **deferred**. Legacy `sp_combobox_*` helpers are kept as
>   thin wrappers.

## Problem with the current variant system

`Combobox::Variant` is an immutable struct that encodes all popup metadata for the four built-in
panel types. Every touch-point in the helper layer depends on this struct:

```ruby
variant  = variant_class.variant            # class-method call — not swappable via registry
panel_id = variant.popup_id_for(panel_id)   # suffix baked into variant metadata
haspopup = variant.haspopup                 # listbox vs dialog baked in
opts     = variant.opts(**overrides)        # per-variant default kwargs merged here
```

**Consequences:**

- No way to add a new panel type without adding a `Variant` class and a new `sp_combobox_*` helper
- Custom / arbitrary panel content is impossible
- `sp_render_combobox(variant_class, id, opts, **kwargs, &block)` receives the variant class as a
  value — can't be replaced via a component registry
- `STIMULUS_CONTROLLER` constants across `Dropdown`, `Typeahead`, `Date`, `Time` reference
  `Combobox::STIMULUS_CONTROLLER` and `Popover::STIMULUS_CONTROLLER` at class-load time —
  registering a custom class does nothing for the Stimulus action wiring

---

## Design goals

1. **Single `sp_combobox` entry point** — panel type set by block method call, not helper name
2. **Block-based panel DSL** — Ruby/Rails convention; yielded builder object, methods return `nil`
3. **ARIA derived from panel type** — no separate `Variant` struct needed
4. **Extensible panels** — drop-in custom panel content without subclassing
5. **Keep `sp_combobox_*` wrappers** — backward compat, thin delegation to `sp_combobox`
6. **Form builder unchanged externally** — `f.field(:country, as: :select)` API stays the same

---

## New helper API

```erb
<%# Dropdown — panel IS the <ul role="listbox"> %>
<%= sp_combobox(value: "us", label: "Country") do |c|
  c.dropdown do |d|
    d.option("United States", value: "us")
    d.option("Canada", value: "ca")
    d.option_group("Americas") do |g|
      g.option("Mexico", value: "mx")
    end
  end
%>

<%# Typeahead — client-side options %>
<%= sp_combobox(label: "City") do |c|
  c.typeahead do |d|
    d.option("London", value: "london")
    d.option("Paris", value: "paris")
  end
%>

<%# Typeahead — server-side fetch %>
<%= sp_combobox(label: "City") do |c|
  c.typeahead(url: cities_path, field: "q", delay: 300, min_length: 2)
%>

<%# Date picker %>
<%= sp_combobox(value: "2024-03-15", label: "Birthday") do |c|
  c.date
%>

<%# Time picker %>
<%= sp_combobox(label: "Meeting time") do |c|
  c.time(format: :h12, step: 15)
%>

<%# Custom panel — arbitrary block content (new capability) %>
<%= sp_combobox(label: "Color") do |c|
  c.custom(haspopup: "dialog") do
    render "shared/color_picker_panel"
  end
%>
```

Shared wrapper options: `value:`, `label:`, `id:`, `close_on_select:`, `format:` (for
`input-formatter`), `**html_options` forwarded to the wrapper `<div>`.

---

## Backward-compat wrappers (keep unchanged API)

```ruby
def sp_combobox_dropdown(options: [], value: nil, label: nil, **kwargs)
  sp_combobox(value: value, label: label, **kwargs) do |c|
    c.dropdown(options: options, value: value, label: label)
  end
end

def sp_combobox_typeahead(options: [], value: nil, label: nil, url: nil, **kwargs)
  sp_combobox(value: value, label: label, **kwargs) do |c|
    c.typeahead(options: options, value: value, label: label, url: url)
  end
end

def sp_combobox_date(value: nil, label: nil, **kwargs)
  sp_combobox(value: value, label: label, format: "date", **kwargs) do |c|
    c.date(value: value)
  end
end

def sp_combobox_time(format: :h12, step: 1, value: nil, label: nil, **kwargs)
  sp_combobox(value: value, label: label, format: "time", **kwargs) do |c|
    c.time(format: format, step: step, value: value)
  end
end
```

---

## Architecture

```
sp_combobox { |c| c.dropdown { ... } }
  → Combobox.new(template).render(...)
       yields Combobox::Builder to block
       builder.dropdown sets @panel = Panel::Dropdown.new(opts, block)
       panel.haspopup, panel.popup_id_suffix → drive trigger ARIA
       render:
         Combobox::Trigger → <input role="combobox" aria-haspopup="listbox" ...>
         <input type="hidden" ...>
         panel.render(popup_id, label) → <ul role="listbox" id="...">
```

### Panel type → ARIA mapping

| Panel method          | `aria-haspopup` | `aria-controls` target                        | Popup ID               |
| --------------------- | --------------- | --------------------------------------------- | ---------------------- |
| `c.dropdown`          | `"listbox"`     | `<ul role="listbox">` (= panel root)          | `{id}_popover`         |
| `c.typeahead`         | `"listbox"`     | `<ul role="listbox">` (nested inside wrapper) | `{id}_popover_listbox` |
| `c.date`              | `"dialog"`      | `<div role="dialog">` (= panel root)          | `{id}_popover`         |
| `c.time`              | `"dialog"`      | `<div role="dialog">` (= panel root)          | `{id}_popover`         |
| `c.custom(haspopup:)` | caller-supplied | `{id}_popover`                                | `{id}_popover`         |

---

## Component design

### `Combobox::Builder`

Yielded to the caller. Methods return `nil` (ERB-safe). Stores a single panel config.

```ruby
class Combobox::Builder
  attr_reader :panel

  def dropdown(**opts, &block) = set_panel(Panel::Dropdown, opts, block)
  def typeahead(**opts, &block) = set_panel(Panel::Typeahead, opts, block)
  def date(**opts)             = set_panel(Panel::Date, opts, nil)
  def time(**opts)             = set_panel(Panel::Time, opts, nil)
  def custom(**opts, &block)   = set_panel(Panel::Custom, opts, block)

  private

  def set_panel(klass, opts, block)
    @panel = klass.new(opts, block)
    nil
  end
end
```

### `Combobox` (redesigned)

```ruby
class Combobox < Plumber::Base
  STIMULUS_CONTROLLER = "input-combobox"
  FORMAT_CONTROLLER   = "input-formatter"
  FORMAT_ACTION       = "input-combobox:changed->input-formatter#format"

  def render(value: nil, id: nil, label: nil, close_on_select: nil, format: nil, **kwargs, &block)
    builder = Combobox::Builder.new
    yield builder if block_given?

    panel     = builder.panel
    base_id   = id || sp_dom_id
    panel_id  = "#{base_id}_popover"
    popup_id  = panel&.popup_id_for(panel_id)  || panel_id
    haspopup  = panel&.haspopup                || "dialog"

    template.content_tag(:div, **wrapper_attrs(value, close_on_select, format, kwargs)) do
      Components::Popover.new(template).build(panel_id: panel_id) do |p|
        p.trigger(haspopup: haspopup, controls: popup_id) do |attrs|
          build_trigger(attrs, base_id, value, label, panel)
        end
        p.build_panel(classes: theme.resolve(:combobox_popover).fetch(:classes, "")) do |panel_attrs|
          panel&.render(template, panel_attrs: panel_attrs, popup_id: popup_id, label: label)
        end
      end
    end
  end

  private

  def build_trigger(popover_attrs, id, value, label, panel)
    template.safe_join([
      Combobox::Trigger.new(template).render(
        stimulus_controller: STIMULUS_CONTROLLER,
        popover: popover_attrs,
        id: id,
        aria: ({ label: label } if label),
        icon_trailing: panel&.trigger_icon,
        readonly: panel&.readonly_trigger?,
        **panel&.trigger_opts || {}
      ),
      hidden_input(id, value)
    ])
  end

  def wrapper_attrs(value, close_on_select, format, kwargs)
    data = {
      controller: "#{Popover::STIMULUS_CONTROLLER} #{STIMULUS_CONTROLLER} #{FORMAT_CONTROLLER}",
      action:     FORMAT_ACTION
    }
    data[:input_combobox_value_value]    = value          if value.present?
    data[:popover_close_on_select_value] = close_on_select unless close_on_select.nil?
    data[:input_formatter_format_value]  = format          if format.present?
    merge_html_options(theme.resolve(:combobox), kwargs, { data: data })
  end

  def hidden_input(id, value)
    template.tag.input(
      type: "hidden", id: id, value: value,
      data: { "#{STIMULUS_CONTROLLER}_target": "input" }
    )
  end
end
```

### Panel base contract

Each panel class implements:

```ruby
class Combobox::Panel::Base
  def initialize(opts, block) = (@opts = opts; @block = block)
  def haspopup         = raise NotImplementedError
  def popup_id_for(id) = id                  # override for typeahead (_listbox suffix)
  def trigger_icon     = nil                 # override for date ("calendar"), time ("clock")
  def trigger_opts     = {}                  # override for typeahead (aria-autocomplete etc.)
  def readonly_trigger? = true               # override for typeahead (false)
  def render(template, panel_attrs:, popup_id:, label:) = raise NotImplementedError
end
```

### Panel implementations

**`Panel::Dropdown`**

```ruby
class Combobox::Panel::Dropdown < Panel::Base
  def haspopup    = "listbox"
  def trigger_icon = "chevron-down"

  def render(template, panel_attrs:, popup_id:, label:, **)
    options = @opts.delete(:options) { [] }
    value   = @opts.delete(:value)
    Combobox::Dropdown.new(template).render(
      panel_attrs: panel_attrs, options: options, value: value, label: label
    )
  end
end
```

**`Panel::Typeahead`**

```ruby
class Combobox::Panel::Typeahead < Panel::Base
  def haspopup          = "listbox"
  def popup_id_for(id)  = "#{id}_listbox"
  def readonly_trigger? = false
  def trigger_opts      = { aria: { autocomplete: "list" } }

  def render(template, panel_attrs:, popup_id:, label:, **)
    Combobox::Typeahead.new(template).render(
      panel_attrs: panel_attrs,
      options: @opts[:options] || [],
      value: @opts[:value],
      label: label,
      url: @opts[:url]
    )
  end
end
```

**`Panel::Date`**

```ruby
class Combobox::Panel::Date < Panel::Base
  def haspopup     = "dialog"
  def trigger_icon = "calendar"

  def render(template, panel_attrs:, popup_id:, label:, **)
    Combobox::Date.new(template).render(panel_attrs: panel_attrs, value: @opts[:value])
  end
end
```

**`Panel::Time`**

```ruby
class Combobox::Panel::Time < Panel::Base
  def haspopup     = "dialog"
  def trigger_icon = "clock"

  def render(template, panel_attrs:, popup_id:, label:, **)
    Combobox::Time.new(template).render(
      panel_attrs: panel_attrs,
      format: @opts.fetch(:format, :h12),
      step:   @opts.fetch(:step, 1),
      value:  @opts[:value]
    )
  end
end
```

**`Panel::Custom`**

```ruby
class Combobox::Panel::Custom < Panel::Base
  def haspopup = @opts.fetch(:haspopup, "dialog")

  def render(template, panel_attrs:, popup_id:, label:, **)
    template.capture(panel_attrs, &@block) if @block
  end
end
```

---

## Deleted

| File                                | Replaced by                                             |
| ----------------------------------- | ------------------------------------------------------- |
| `components/combobox/variant.rb`    | Panel class `haspopup` / `popup_id_for` methods         |
| `sp_render_combobox` private helper | `Combobox.new(template).render(...)` with builder block |

---

## New files

| File                                     | Purpose                                   |
| ---------------------------------------- | ----------------------------------------- |
| `components/combobox/builder.rb`         | DSL object yielded to `sp_combobox` block |
| `components/combobox/panel/base.rb`      | Contract for panel implementations        |
| `components/combobox/panel/dropdown.rb`  | Dropdown panel                            |
| `components/combobox/panel/typeahead.rb` | Typeahead panel                           |
| `components/combobox/panel/date.rb`      | Date picker panel                         |
| `components/combobox/panel/time.rb`      | Time picker panel                         |
| `components/combobox/panel/custom.rb`    | Arbitrary block content panel             |

---

## Modified files

| File                             | Change                                                   |
| -------------------------------- | -------------------------------------------------------- |
| `components/combobox.rb`         | Builder-based render; removes variant lookup             |
| `helpers/combobox_helper.rb`     | Adds `sp_combobox`; `sp_combobox_*` become thin wrappers |
| `form/fields/inputs/combobox.rb` | Use `sp_combobox` internally                             |
| `form/fields/inputs/datetime.rb` | Use `c.date` / `c.time` panel blocks                     |
| `form/fields/inputs/select.rb`   | Use `c.dropdown` panel block                             |
| `form/fields/inputs/search.rb`   | Use `c.typeahead` panel block                            |

---

## ARIA notes

- `aria-haspopup` and `aria-controls` on the trigger are now derived from `panel.haspopup` and
  `panel.popup_id_for(panel_id)` — no `Variant` struct involved.
- Typeahead still needs `data-input-combobox-combobox-dropdown-outlet` pointing at the wrapper
  panel ID (for the outlet wiring that lets `input-combobox#onInput` call `filter`). This moves
  from the helper into `Combobox#wrapper_attrs` when panel type is typeahead.
- `close_on_select` stays on the wrapper (`data-popover-close-on-select-value`), unchanged.
- `input-formatter` format and options values stay on the wrapper, set from `sp_combobox` kwargs.

---

## Form builder — no external change

```erb
<%= f.field(:country, as: :select) %>
<%= f.field(:birthday, as: :date) %>
<%= f.field(:city, as: :search, url: cities_path) %>
```

Internally, `render_combobox_dropdown` / `render_combobox_date` etc. in `form/fields/inputs/`
call `sp_combobox { |c| c.dropdown { ... } }` instead of `sp_combobox_dropdown(...)`.

---

## Testing notes

- Unit tests for each `Panel::*` class: assert `haspopup`, `popup_id_for`, `trigger_icon`
- Unit test for `Combobox::Builder`: assert panel is set and returns nil
- Existing `sp_combobox_*` helper tests should pass unchanged (backward compat)
- A11y tests: closed and open states per variant, same as current
- `sp_combobox` with `c.custom(...)` — new a11y test with a simple custom dialog panel
