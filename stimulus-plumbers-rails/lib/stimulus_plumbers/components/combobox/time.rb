# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Combobox
      # Renders an iOS-style drum/wheel time picker as the dialog popover body.
      # Wires InputTimepickerController and dispatches input-timepicker:changed → InputComboboxController.
      class Time < Plumber::Base
        PICKER_CONTROLLER = "input-timepicker"

        def render(format: :h12, step: 1, value: nil, **_kwargs)
          @format = format
          @step   = [1, step.to_i].max
          @time   = parse_time(value)

          template.content_tag(
            :div,
            data: {
              controller: PICKER_CONTROLLER,
              action:     "#{PICKER_CONTROLLER}:changed->input-combobox#onValueChanged"
            }
          ) do
            template.safe_join(drums)
          end
        end

        private

        def drums
          cols = [hour_drum, minute_drum]
          cols << period_drum if @format == :h12
          cols
        end

        def hour_drum
          drum.render(target: "hour", label: "Hour", items: hour_items, selected: current_hour)
        end

        def minute_drum
          items = (0...60).step(@step).map do |m|
            s = m.to_s.rjust(2, "0")
            [s, s]
          end
          selected = @time ? snap_minute(@time.min).to_s.rjust(2, "0") : nil
          drum.render(target: "minute", label: "Minute", items: items, selected: selected)
        end

        def period_drum
          selected = if @time
                       @time.hour < 12 ? "AM" : "PM"
                     end
          drum.render(target: "period", label: "Period", items: [%w[AM AM], %w[PM PM]], selected: selected)
        end

        def hour_items
          if @format == :h12
            (1..12).map { |h| [h.to_s, h.to_s] }
          else
            (0..23).map do |h|
              s = h.to_s.rjust(2, "0")
              [s, s]
            end
          end
        end

        def current_hour
          return nil unless @time

          if @format == :h12
            h = @time.hour % 12
            (h.zero? ? 12 : h).to_s
          else
            @time.hour.to_s.rjust(2, "0")
          end
        end

        def snap_minute(minute)
          return minute if @step == 1

          ((minute.to_f / @step).round * @step) % 60
        end

        def drum
          TimePicker::Renderer.new(template)
        end

        def parse_time(value)
          return nil if value.nil? || value.to_s.strip.empty?

          ::Time.parse(value.to_s)
        rescue ArgumentError
          nil
        end
      end
    end
  end
end
