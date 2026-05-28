# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Date < Plumber::Base
        STIMULUS_CONTROLLER = "combobox-date"
        CALENDAR_OUTLET = "#{STIMULUS_CONTROLLER}-calendar-month-outlet".freeze

        def self.default_opts
          {
            input:   { data: { combobox_date_date_value: nil } },
            popover: { aria: { label: "Picker" }, role: "dialog", tag: :div }
          }
        end

        def self.calendar_id_for(popover_id)
          [popover_id, "calendar"].compact.join("_")
        end

        def render(...)
          render_date(...)
        end

        private

        def render_date(value: nil, popover_id: nil)
          calendar_id = self.class.calendar_id_for(popover_id)

          data = {
            controller:          STIMULUS_CONTROLLER,
            CALENDAR_OUTLET  => "##{calendar_id}",
            action:              [
              "calendar-month-observer:selected->#{STIMULUS_CONTROLLER}#onSelect",
              "#{STIMULUS_CONTROLLER}:selected->#{Combobox::STIMULUS_CONTROLLER}#onSelect"
            ].join(" "),
            "#{STIMULUS_CONTROLLER}-date-value" => value
          }.compact

          template.content_tag(:div, data: data) do
            template.safe_join([navigation, calendar_month(id: calendar_id)])
          end
        end

        def navigation
          DatePicker::Navigation.new(template).render(
            step:                "month",
            stimulus_controller: STIMULUS_CONTROLLER
          )
        end

        def calendar_month(**kwargs)
          Calendar.new(template).month(**kwargs)
        end
      end
    end
  end
end
