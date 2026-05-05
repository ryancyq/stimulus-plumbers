# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Combobox
      # Renders the date picker popover body: navigation + calendar grid.
      # Wires ComboboxDateController; dispatches combobox-date:selected → InputComboboxController.
      class Date < Plumber::Base
        PICKER_CONTROLLER   = "combobox-date"
        CALENDAR_OUTLET_KEY = "#{PICKER_CONTROLLER.tr("-", "_")}_calendar_month_outlet".freeze

        def self.default_opts
          {
            input:   { data: { combobox_date_date_value: nil } },
            popover: { label: "Picker", role: "dialog", tag: :div }
          }
        end

        def render(value: nil, **_kwargs)
          calendar_id = "combobox_date_#{SecureRandom.hex(8)}_calendar"

          template.content_tag(
            :div,
            data: {
              controller:        PICKER_CONTROLLER,
              CALENDAR_OUTLET_KEY => "##{calendar_id}",
              action:            [
                "calendar-month-observer:selected->#{PICKER_CONTROLLER}#onSelected",
                "#{PICKER_CONTROLLER}:selected->input-combobox#onSelected"
              ].join(" ")
            }.tap { |d| d["#{PICKER_CONTROLLER.tr("-", "_")}_date_value"] = value if value }
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
