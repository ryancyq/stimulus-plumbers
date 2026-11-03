# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      # A read-only date input whose popover holds sp_calendar.
      class Date < Temporal
        STIMULUS_CONTROLLER = "combobox-date"
        FORMAT              = "date"
        ICON                = "calendar"
        POPOVER_KEY         = :combobox_date_popover
        ACTIONS             = ["calendar:changed->#{STIMULUS_CONTROLLER}#onChange"].freeze
        AVAILABILITY        = Dates::Availability

        # `calendar:` goes to the `:stimulus` sp_calendar.
        def render(calendar: {}, **kwargs)
          @calendar = calendar.merge(kwargs.extract!(*AVAILABILITY::OPTIONS))
          super(**kwargs)
        end

        private

        # A value that is not a date renders as text and selects nothing.
        def parse(value)
          Dates.parse_key(value)
        end

        def key_for(date)
          date.iso8601
        end

        def outlet_data
          { "#{STIMULUS_CONTROLLER}-calendar-outlet" => "##{@id}_calendar" }
        end

        def render_panel(panel_attrs)
          template.content_tag(:div, **panel_attrs) do
            Calendar.new(template).render(
              id: "#{@id}_calendar", selected: @value, selectable: true, **@calendar, displayed: @calendar[:displayed] || @value
            )
          end
        end
      end
    end
  end
end
