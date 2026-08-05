# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Progress
      # Shared stimulus/ARIA wiring and value formatting for the progress variants
      # (bar, segmented, ring, meter) and for the range form field, which reuses the readout.
      module Shared
        FORMATS = %i[percent value value_max].freeze

        private

        def progress_stimulus_data(value:, min:, max:, variant:, **extra)
          {
            data: {
              controller:               "progress",
              "progress-variant-value": variant,
              "progress-current-value": value,
              "progress-min-value":     min,
              "progress-max-value":     max,
              **extra
            }
          }
        end

        def progress_aria(value:, min:, max:, indeterminate: false, valuetext: nil)
          aria = { valuemin: min, valuemax: max }
          aria[:valuenow]  = value unless indeterminate
          aria[:valuetext] = valuetext if valuetext
          aria
        end

        def validate_format!(format)
          return if format.nil? || (format.respond_to?(:to_sym) && FORMATS.include?(format.to_sym))

          raise ArgumentError, "unknown format: #{format.inspect} (expected one of #{FORMATS.join(", ")})"
        end

        # Keep in sync with the progress controller's formattedValue().
        def value_text(format, current, min, max)
          case format&.to_sym
          when :percent   then "#{percent(current, min, max).round}%"
          when :value     then integral(current).to_s
          when :value_max then "#{integral(current)} / #{integral(max)}"
          end
        end

        # Comparable#clamp raises when min > max; the JS returns max there, and percent() then yields 0%.
        def clamp(value, min, max)
          return max if max < min

          value.clamp(min, max)
        end

        def percent(current, min, max)
          range = max - min
          range <= 0 ? 0 : (current - min).fdiv(range) * 100
        end

        # A `step: 0.1` range holds 45.5 — to_i would paint a 45 fill under a 45.5 thumb.
        def numeric(value)
          return value if value.is_a?(Numeric)

          Float(value, exception: false) || 0
        end

        # 45.0 renders as "45" — JS has no Float/Integer distinction to mirror.
        def integral(number)
          (number % 1).zero? ? number.to_i : number
        end
      end
    end
  end
end
