# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      # A read-only time input whose popover holds hour, minute, and AM/PM columns.
      class Time < Temporal
        STIMULUS_CONTROLLER = "combobox-time"
        FORMAT              = "time"
        ICON                = "clock"
        POPOVER_KEY         = :combobox_time_popover
        ACTIONS             = [
          "popover:before-open->#{STIMULUS_CONTROLLER}#onOpening",
          "popover:opened->#{STIMULUS_CONTROLLER}#onOpened"
        ].freeze

        # `step:` is the minute interval; a minute off it selects no minute.
        def render(step: 1, **kwargs)
          @step = [1, step.to_i].max
          super(**kwargs)
        end

        private

        # [hour, minute] from a time or an "HH:MM" string; anything else renders as text.
        def parse(value)
          return [value.hour, value.min] if value.respond_to?(:hour) && value.respond_to?(:min)

          match = value.to_s.match(%r{\A(\d{1,2}):(\d{2})})
          [match[1].to_i, match[2].to_i] if match && match[1].to_i < 24 && match[2].to_i < 60
        end

        def key_for((hour, minute))
          format("%<hour>02d:%<minute>02d", hour: hour, minute: minute)
        end

        # The columns follow `hourCycle` or `hour12`, 12-hour by default.
        def format_options(format)
          return super unless format.respond_to?(:to_h)

          { hourCycle: "h12" }.merge(super)
        end

        def twelve_hour?
          return true unless @format.is_a?(Hash)

          @format.fetch(:hour12) { %w[h11 h12].include?(@format[:hourCycle].to_s) }
        end

        def render_panel(panel_attrs)
          template.content_tag(:div, **merge_html_options(panel_attrs, theme.resolve(:combobox_time))) do
            Columns.new(template).render(
              id:          @id,
              controller:  STIMULUS_CONTROLLER,
              value:       @value,
              step:        @step,
              twelve_hour: twelve_hour?
            )
          end
        end
      end
    end
  end
end
