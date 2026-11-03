# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      # A read-only date-time input whose popover holds sp_calendar and the time columns.
      class Datetime < Time
        STIMULUS_CONTROLLER = "combobox-datetime"
        FORMAT              = "datetime"
        ICON                = "calendar"
        POPOVER_KEY         = :combobox_datetime_popover
        ACTIONS             = [
          "calendar:changed->#{STIMULUS_CONTROLLER}#onDateChange",
          "popover:before-open->#{STIMULUS_CONTROLLER}#onOpening",
          "popover:opened->#{STIMULUS_CONTROLLER}#onOpened",
          "popover:closed->#{STIMULUS_CONTROLLER}#onClosed"
        ].freeze
        ESCAPE_ACTION       = "keydown.esc->#{STIMULUS_CONTROLLER}#onEscape".freeze
        AVAILABILITY        = Datetimes::Availability

        # Options: Datetimes::Availability::OPTIONS, with `time:` taking Times::Availability::OPTIONS;
        # `calendar:` goes to the `:stimulus` sp_calendar.
        def render(calendar: {}, **kwargs)
          @calendar = calendar
          super(**kwargs)
        end

        private

        # A date-time key from a time in Time.zone or a date-time key; anything else renders as text.
        def parse(value)
          Datetimes.parse_key(value)
        end

        def canonical(key)
          key
        end

        def availability_values
          {
            "combobox-datetime-min-value"      => @availability.min,
            "combobox-datetime-max-value"      => @availability.max,
            "combobox-datetime-time-min-value" => @availability.time.min,
            "combobox-datetime-time-max-value" => @availability.time.max,
            "combobox-datetime-step-value"     => @availability.time.step
          }.compact
        end

        def render_panel(panel_attrs)
          date = @value && ::Date.iso8601(@value[0, 10])
          attrs = merge_html_options(panel_attrs, theme.resolve(:combobox_datetime), { data: { action: ESCAPE_ACTION } })
          template.content_tag(:div, **attrs) do
            template.safe_join([render_calendar(date), render_columns(date)])
          end
        end

        def render_calendar(date)
          Calendar.new(template).render(
            id:         "#{@id}_calendar",
            selected:   date,
            selectable: true,
            **@calendar,
            **date_options,
            displayed:  @calendar[:displayed] || date,
            data:       { "#{STIMULUS_CONTROLLER}-target" => "calendar" }
          )
        end

        def date_options
          dates = @availability.date_availability
          Dates::Availability::OPTIONS.to_h { |name| [name, dates.public_send(name)] }
        end

        # The chosen date's times, or the daily window before a date is chosen.
        def render_columns(date)
          template.content_tag(:div, **merge_html_options(theme.resolve(:combobox_time))) do
            Time::Columns.new(template).render(
              id:           @id,
              controller:   STIMULUS_CONTROLLER,
              value:        @value && @value[11, 5].split(":").map(&:to_i),
              availability: date ? @availability.day_availability(date) : @availability.time,
              twelve_hour:  twelve_hour?
            )
          end
        end
      end
    end
  end
end
