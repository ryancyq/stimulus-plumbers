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
            popover: { label: "Picker", role: "dialog", tag: :div }
          }
        end

        def render(value: nil, **_kwargs)
          calendar_id = "combobox_date_#{SecureRandom.hex(8)}_calendar"

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

        private

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
