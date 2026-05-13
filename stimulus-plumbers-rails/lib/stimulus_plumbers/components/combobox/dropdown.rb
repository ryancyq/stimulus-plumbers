# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Dropdown < Plumber::Base
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
          listbox_attrs = merge_html_options(
            { classes: theme.resolve(:combobox_listbox).fetch(:classes, "") },
            { role: "listbox", data: { "#{STIMULUS_CONTROLLER}_target": "listbox" } }
          )
          listbox_attrs[:aria] = { label: label } if label

          template.content_tag(:ul, **listbox_attrs) do
            Options.new(template).render(options, value: value)
          end
        end
      end
    end
  end
end
