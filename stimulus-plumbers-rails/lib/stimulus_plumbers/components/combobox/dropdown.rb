# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Combobox
      # Renders a static listbox popover body with combobox-dropdown controller.
      # Supports flat options, descriptions, and option groups.
      class Dropdown < Plumber::Base
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
            }
          }
        end

        def render(options: [], value: nil, **_kwargs)
          listbox = template.content_tag(
            :ul,
            role: "listbox",
            data: { "#{DROPDOWN_CONTROLLER}_target": "listbox" }
          ) do
            render_items(options, value: value)
          end

          template.safe_join([listbox])
        end
      end
    end
  end
end
