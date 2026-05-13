# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      # Renders a static listbox popover body with combobox-dropdown controller.
      # Supports flat options, descriptions, and option groups.
      class Dropdown < Plumber::Base
        include OptionGroup

        STIMULUS_CONTROLLER = "combobox-dropdown"
        STIMULUS_ACTION     = [
          "click->#{STIMULUS_CONTROLLER}#select",
          "keydown->#{STIMULUS_CONTROLLER}#navigate",
          "#{STIMULUS_CONTROLLER}:selected->#{Combobox::STIMULUS_CONTROLLER}#onSelected"
        ].join(" ").freeze

        def self.default_opts
          {
            popover: {
              tag:      :div,
              haspopup: "listbox",
              data:     { controller: STIMULUS_CONTROLLER, action: STIMULUS_ACTION }
            }
          }
        end

        def render(options: [], value: nil, label: nil, **_kwargs)
          listbox_attrs = { role: "listbox", data: { "#{STIMULUS_CONTROLLER}_target": "listbox" } }
          listbox_attrs[:aria] = { label: label } if label

          template.content_tag(:ul, **listbox_attrs) do
            render_items(options, value: value)
          end
        end
      end
    end
  end
end
