# frozen_string_literal: true

module StimulusPlumbers
  module Times
    # The times a field offers. Times are time objects or time keys; `step` is minutes counted from midnight.
    class Availability
      OPTIONS = %i[min max step].freeze
      STEPS   = [1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60].freeze

      attr_reader :min, :max, :step, :ranges

      def initialize(min: nil, max: nil, step: 1)
        @min = min && parse_key!(min, :min)
        @max = max && parse_key!(max, :max)
        raise ArgumentError, "step must be one of #{STEPS.join(", ")}" unless STEPS.include?(step)

        @step   = step
        @ranges = window_ranges
        raise ArgumentError, "min and max leave no time on the step" if empty?
      end

      # `key` is a time key.
      def disabled?(key)
        outside_window?(key) || !(key[3, 2].to_i % step).zero?
      end

      # In no range of the window.
      def outside_window?(key)
        ranges.none? { |start, finish| key.between?(start, finish) }
      end

      # A `min` after `max` wraps past midnight.
      def wraps?
        min && max && min > max
      end

      def hour_disabled?(hour)
        (0..59).all? { |minute| disabled?(Times.key(hour, minute)) }
      end

      # No hour has an available minute.
      def empty?
        HOURS.all? { |hour| hour_disabled?(hour) }
      end

      private

      # Inclusive [start, finish] time keys; a window that wraps past midnight is two ranges.
      def window_ranges
        start  = min || "00:00"
        finish = max || "23:59"
        wraps? ? [["00:00", finish], [start, "23:59"]] : [[start, finish]]
      end

      def parse_key!(value, name)
        Times.parse_key(value) || raise(ArgumentError, "#{name} must be a time or time key")
      end
    end
  end
end
