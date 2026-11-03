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
        AVAILABILITY        = Times::Availability
        ACTIONS             = [
          "popover:before-open->#{STIMULUS_CONTROLLER}#onOpening",
          "popover:opened->#{STIMULUS_CONTROLLER}#onOpened",
          "popover:closed->#{STIMULUS_CONTROLLER}#onClosed"
        ].freeze

        # Options: Times::Availability::OPTIONS; a minute off the `step:` chooses no minute.
        def render(**kwargs)
          @availability = self.class::AVAILABILITY.new(**kwargs.extract!(*self.class::AVAILABILITY::OPTIONS))
          super
        end

        private

        # [hour, minute] from a time or a time key; anything else renders as text.
        def parse(value)
          Times.parse_key(value)&.split(":")&.map(&:to_i)
        end

        def canonical((hour, minute))
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

        def root_attrs(kwargs)
          merge_html_options(super, { data: availability_values })
        end

        def availability_values
          {
            "combobox-time-min-value"  => @availability.min,
            "combobox-time-max-value"  => @availability.max,
            "combobox-time-step-value" => @availability.step
          }.compact
        end

        def render_panel(panel_attrs)
          template.content_tag(:div, **merge_html_options(panel_attrs, theme.resolve(:combobox_time))) do
            Columns.new(template).render(
              id:           @id,
              controller:   STIMULUS_CONTROLLER,
              value:        @value,
              availability: @availability,
              twelve_hour:  twelve_hour?
            )
          end
        end
      end
    end
  end
end
