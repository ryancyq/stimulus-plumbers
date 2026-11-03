# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Date < Temporal
        STIMULUS_CONTROLLER = "combobox-date"
        FORMAT              = "date"
        ICON                = "calendar"
        POPOVER_KEY         = :combobox_date_popover
        ACTIONS             = [
          "calendar:changed->#{STIMULUS_CONTROLLER}#onChange",
          "popover:before-open->#{STIMULUS_CONTROLLER}#onOpening"
        ].freeze
        AVAILABILITY = Dates::Availability

        def render(calendar: {}, **kwargs)
          @calendar = calendar.merge(kwargs.extract!(*AVAILABILITY::OPTIONS))
          super(**kwargs)
        end

        private

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
