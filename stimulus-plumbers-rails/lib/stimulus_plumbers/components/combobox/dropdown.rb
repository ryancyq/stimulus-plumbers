# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Dropdown < Plumber::Base
        STIMULUS_CONTROLLER = "combobox-dropdown"
        STIMULUS_ACTION     = [
          "click->#{STIMULUS_CONTROLLER}#onSelect",
          "keydown->#{STIMULUS_CONTROLLER}#onNavigate",
          "#{STIMULUS_CONTROLLER}:selected->#{Combobox::STIMULUS_CONTROLLER}#onSelect",
          "#{STIMULUS_CONTROLLER}:selected->#{Components::Popover::STIMULUS_CONTROLLER}#closeOnSelect"
        ].join(" ").freeze

        module Metadata
          module_function

          def haspopup
            "listbox"
          end

          def popup_id_for(panel_id)
            panel_id
          end

          def trigger_icon
            "chevron-down"
          end

          def trigger_options
            {}
          end

          def stimulus_data(_panel_id, _options)
            {}
          end
        end

        def render(...)
          render_dropdown(...)
        end

        private

        def render_dropdown(panel_attrs: {}, options: [], value: nil, label: nil, labelledby: nil)
          template.content_tag(
            :ul,
            Options.new(template).render(options, value: value),
            **listbox_attrs(panel_attrs: panel_attrs, label: label, labelledby: labelledby)
          )
        end

        def listbox_attrs(panel_attrs: {}, label: nil, labelledby: nil)
          merge_html_options(
            panel_attrs,
            theme.resolve(:combobox_listbox),
            {
              role: "listbox",
              aria: labelled_aria(label, labelledby: labelledby),
              data: { controller: STIMULUS_CONTROLLER, action: STIMULUS_ACTION, combobox_dropdown_target: "listbox" }
            }
          )
        end
      end
    end
  end
end
