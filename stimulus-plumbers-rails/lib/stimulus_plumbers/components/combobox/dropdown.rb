# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Dropdown < Plumber::Base
        STIMULUS_CONTROLLER = "combobox-dropdown"
        STIMULUS_ACTION     = [
          "click->#{STIMULUS_CONTROLLER}#select",
          "keydown->#{STIMULUS_CONTROLLER}#onNavigate",
          "#{STIMULUS_CONTROLLER}:selected->#{Combobox::STIMULUS_CONTROLLER}#onSelect"
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

        def render(options: [], value: nil, label: nil, labelledby: nil)
          listbox_attrs = merge_html_options(
            { classes: theme.resolve(:combobox_listbox).fetch(:classes, "") },
            { role: "listbox", data: { "#{STIMULUS_CONTROLLER}_target": "listbox" } }
          )
          if labelledby
            listbox_attrs[:aria] = { labelledby: labelledby }
          elsif label
            listbox_attrs[:aria] = { label: label }
          end

          template.content_tag(:ul, **listbox_attrs) do
            Options.new(template).render(options, value: value)
          end
        end
      end
    end
  end
end
