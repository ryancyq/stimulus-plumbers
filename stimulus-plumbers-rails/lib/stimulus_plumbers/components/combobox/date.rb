# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Combobox
      # Renders the date picker popup content: month navigation + calendar grid.
      # Intended to be embedded inside the popup of a Combobox::Renderer shell.
      #
      # Wires:
      #   - InputDatepickerController for navigation and display drawing
      #   - CalendarMonthController + CalendarMonthObserverController (via Calendar::Renderer)
      #   - Dispatches input-datepicker:changed → InputComboboxController#onValueChanged
      class Date < Plumber::Base
        PICKER_CONTROLLER   = "input-datepicker"
        # Rails dasherizes underscores: input_datepicker_calendar_month_outlet
        # → data-input-datepicker-calendar-month-outlet
        CALENDAR_OUTLET_KEY = "#{PICKER_CONTROLLER.tr("-", "_")}_calendar_month_outlet"

        def render(calendar_id:, popup_id:, **_kwargs)
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
            stimulus_controller: PICKER_CONTROLLER,
            step:                "month"
          )
        end

        def calendar_month(**kwargs)
          Calendar::Renderer.new(template).month(**kwargs)
        end
      end
    end
  end
end
