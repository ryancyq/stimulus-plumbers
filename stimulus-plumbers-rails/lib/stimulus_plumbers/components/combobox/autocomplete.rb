# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      # Renders a listbox popover body for autocomplete.
      # Re-uses combobox-dropdown for selection/filtering; input-combobox relays
      # the trigger input event via the combobox-dropdown outlet.
      class Autocomplete < Plumber::Base
        include OptionGroup

        def self.default_opts
          Dropdown.default_opts.deep_merge(
            trigger: { aria_autocomplete: "list", readonly: false }
          )
        end

        def render(options: [], value: nil, label: nil, **_kwargs)
          listbox_attrs = { role: "listbox", data: { "#{Dropdown::STIMULUS_CONTROLLER}_target": "listbox" } }
          listbox_attrs[:aria] = { label: label } if label

          listbox = template.content_tag(:ul, **listbox_attrs) do
            render_items(options, value: value)
          end

          loading = template.content_tag(
            :div,
            hidden: "",
            aria:   { live: "polite" },
            data:   { "#{Dropdown::STIMULUS_CONTROLLER}_target": "loading" }
          ) { "" }

          empty = template.content_tag(
            :div,
            hidden: "",
            role:   "status",
            data:   { "#{Dropdown::STIMULUS_CONTROLLER}_target": "empty" }
          ) { "No results" }

          template.safe_join([listbox, loading, empty])
        end
      end
    end
  end
end
