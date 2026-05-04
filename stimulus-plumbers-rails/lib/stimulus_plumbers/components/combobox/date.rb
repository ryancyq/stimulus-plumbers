# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Combobox
      # Renders the date picker popover content: month navigation + calendar grid.
      # Wires InputDatepickerController and dispatches input-datepicker:changed → InputComboboxController.
      class Date < Plumber::Base
        PICKER_CONTROLLER   = "input-datepicker"
        # Rails dasherizes underscores: input_datepicker_calendar_month_outlet
        # → data-input-datepicker-calendar-month-outlet
        CALENDAR_OUTLET_KEY = "#{PICKER_CONTROLLER.tr("-", "_")}_calendar_month_outlet".freeze

        def self.default_opts
          {
            input:   { data: { input_datepicker_target: "input" } },
            popover: { label: "Picker", role: "dialog", tag: :div },
            trigger: { data: { input_datepicker_target: "display" } }
          }
        end

        def render(**_kwargs)
          calendar_id = "combobox_date_#{SecureRandom.hex(8)}_calendar"

          template.content_tag(
            :div,
            data: {
              controller:        PICKER_CONTROLLER,
              CALENDAR_OUTLET_KEY => "##{calendar_id}",
              action:            [
                "calendar-month-observer:selected->#{PICKER_CONTROLLER}#selected",
                "#{PICKER_CONTROLLER}:changed->input-combobox#onValueChanged"
              ].join(" ")
            }
          ) do
            template.safe_join([navigation, calendar_month(id: calendar_id)])
          end
        end

        private

        def navigation
          DatePicker::Navigation.new(template).render(
            step:                "month",
            stimulus_controller: PICKER_CONTROLLER
          )
        end

        def calendar_month(**kwargs)
          Calendar::Renderer.new(template).month(**kwargs)
        end
      end
    end
  end
end
