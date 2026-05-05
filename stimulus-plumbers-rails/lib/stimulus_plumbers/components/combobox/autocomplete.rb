# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Combobox
      # Renders a listbox popover body for autocomplete.
      # Re-uses combobox-dropdown for selection/filtering; input-combobox relays
      # the trigger input event via the combobox-dropdown outlet.
      class Autocomplete < Plumber::Base
        include OptionGroup

        DROPDOWN_CONTROLLER = "combobox-dropdown"
        DROPDOWN_ACTION     = [
          "click->combobox-dropdown#select",
          "keydown->combobox-dropdown#navigate",
          "combobox-dropdown:selected->input-combobox#onSelected"
        ].join(" ").freeze

        def self.default_opts
          {
            popover: {
              tag:      :div,
              haspopup: "listbox",
              data:     { controller: DROPDOWN_CONTROLLER, action: DROPDOWN_ACTION }
            },
            trigger: { aria_autocomplete: "list", readonly: false }
          }
        end

        def render(options: [], value: nil, src: nil, label: nil, **_kwargs)
          listbox_attrs = { role: "listbox", data: { "#{DROPDOWN_CONTROLLER}_target": "listbox" } }
          listbox_attrs[:aria] = { label: label } if label

          listbox = template.content_tag(:ul, **listbox_attrs) do
            render_items(options, value: value)
          end

          loading = template.content_tag(
            :div,
            hidden: "",
            aria:   { live: "polite" },
            data:   { "#{DROPDOWN_CONTROLLER}_target": "loading" }
          ) { "" }

          empty = template.content_tag(
            :div,
            hidden: "",
            role:   "status",
            data:   { "#{DROPDOWN_CONTROLLER}_target": "empty" }
          ) { "No results" }

          template.safe_join([listbox, loading, empty])
        end
      end
    end
  end
end
