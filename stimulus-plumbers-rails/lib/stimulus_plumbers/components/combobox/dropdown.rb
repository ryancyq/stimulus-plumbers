# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Dropdown < Plumber::Base
        STIMULUS_CONTROLLER = "combobox-dropdown"
        STIMULUS_ACTION     = [
          "click->#{STIMULUS_CONTROLLER}#select",
          "keydown->#{STIMULUS_CONTROLLER}#onNavigate",
          "#{STIMULUS_CONTROLLER}:selected->#{Combobox::STIMULUS_CONTROLLER}#onSelect",
          "#{STIMULUS_CONTROLLER}:selected->#{Components::Popover::STIMULUS_CONTROLLER}#closeOnSelect"
        ].join(" ").freeze

        def self.default_opts
          {
            popover: {
              tag:      :ul,
              haspopup: "listbox",
              role:     "listbox",
              data:     {
                controller:               STIMULUS_CONTROLLER,
                action:                   STIMULUS_ACTION,
                combobox_dropdown_target: "listbox"
              }
            }
          }
        end

        def render(...)
          render_dropdown(...)
        end

        private

        def render_dropdown(options: [], value: nil)
          Options.new(template).render(options, value: value)
        end
      end
    end
  end
end
