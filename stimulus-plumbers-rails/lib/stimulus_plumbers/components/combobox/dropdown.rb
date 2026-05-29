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

        def self.haspopup = "listbox"
        def self.popup_id(panel_id) = panel_id

        def render(...)
          render_dropdown(...)
        end

        private

        def render_dropdown(panel_attrs: {}, options: [], value: nil, label: nil, labelledby: nil)
          template.content_tag(
            :ul,
            Options.new(template).render(options, value: value),
            **merge_html_options(
              panel_attrs,
              { classes: theme.resolve(:combobox_listbox).fetch(:classes, "") },
              {
                role: "listbox",
                aria: { label: (label unless labelledby), labelledby: labelledby }.compact,
                data: { controller: STIMULUS_CONTROLLER, action: STIMULUS_ACTION, combobox_dropdown_target: "listbox" }
              }
            )
          )
        end
      end
    end
  end
end
