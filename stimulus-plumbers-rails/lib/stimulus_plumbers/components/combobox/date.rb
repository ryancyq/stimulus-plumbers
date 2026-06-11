# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Date < Plumber::Base
        STIMULUS_CONTROLLER = "combobox-date"
        CALENDAR_OUTLET     = "#{STIMULUS_CONTROLLER}-calendar-month-outlet".freeze
        STIMULUS_ACTION     = [
          "calendar-observer:selected->#{STIMULUS_CONTROLLER}#onSelect",
          "#{STIMULUS_CONTROLLER}:selected->#{Combobox::STIMULUS_CONTROLLER}#onSelect",
          "#{STIMULUS_CONTROLLER}:selected->#{Components::Popover::STIMULUS_CONTROLLER}#closeOnSelect"
        ].join(" ").freeze

        def self.calendar_id_for(panel_id)
          [panel_id, "calendar"].compact.join("_")
        end

        module Metadata
          module_function

          def haspopup = "dialog"
          def popup_id_for(panel_id) = panel_id
          def trigger_icon = "calendar"
          def trigger_options = {}
          def stimulus_data(_panel_id, _options) = { input_formatter_format_value: "date" }
        end

        def render(...) = render_date(...)

        private

        def render_date(panel_attrs: {}, value: nil, label: "Picker", labelledby: nil)
          calendar_id = self.class.calendar_id_for(panel_attrs[:id])

          template.content_tag(
            :div,
            **merge_html_options(panel_attrs, dialog_attrs(value, calendar_id, label, labelledby))
          ) do
            template.safe_join([navigation, calendar(id: calendar_id)])
          end
        end

        def dialog_attrs(value, calendar_id, label, labelledby)
          data = {
            controller:      STIMULUS_CONTROLLER,
            CALENDAR_OUTLET  => "##{calendar_id}",
            action:          STIMULUS_ACTION,
            "#{STIMULUS_CONTROLLER}-date-value" => value
          }.compact

          { role: "dialog", aria: labelled_aria(label, labelledby: labelledby), data: data }
        end

        def navigation
          Navigation.new(template).render(
            step:                "month",
            stimulus_controller: STIMULUS_CONTROLLER
          )
        end

        def calendar(**kwargs)
          Calendar.new(template).render(**kwargs)
        end
      end
    end
  end
end
