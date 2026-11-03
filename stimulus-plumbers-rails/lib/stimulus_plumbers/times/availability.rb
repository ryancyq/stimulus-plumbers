# frozen_string_literal: true

module StimulusPlumbers
  module Times
    # The times a field offers. Times are time objects or time keys; `step` is minutes counted from midnight.
    class Availability
      OPTIONS = %i[min max step].freeze
      STEPS   = [1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60].freeze

      attr_reader :min, :max, :step, :from, :to

      def initialize(min: nil, max: nil, step: 1)
        @min = min && key!(min, :min)
        @max = max && key!(max, :max)
        raise ArgumentError, "step must be one of #{STEPS.join(", ")}" unless STEPS.include?(step)

        @step = step
        raise ArgumentError, "min and max leave no time on the step" if empty?
      end

      # `key` is a time key.
      def disabled?(key)
        outside_window?(key) || cut_off?(key) || !(key[3, 2].to_i % step).zero?
      end

      # Before `min` or after `max`; between them when the window wraps past midnight.
      def outside_window?(key)
        return key < min && key > max if wraps?

        (min && key < min) || (max && key > max)
      end

      # A `min` after `max` wraps past midnight.
      def wraps?
        min && max && min > max
      end

      def hour_disabled?(hour)
        (0..59).all? { |minute| disabled?(format("%<hour>02d:%<minute>02d", hour: hour, minute: minute)) }
      end

      # No hour has an available minute.
      def empty?
        (0..23).all? { |hour| hour_disabled?(hour) }
      end

      # A copy that also cuts off the times before `from` and after `to`, time keys that never wrap; it may leave
      # no time.
      def narrow(from: nil, to: nil)
        dup.tap { |copy| copy.cut(from, to) }
      end

      protected

      def cut(from, to)
        @from = from
        @to   = to
      end

      private

      def cut_off?(key)
        (from && key < from) || (to && key > to)
      end

      def key!(value, name)
        Times.parse_key(value) || raise(ArgumentError, "#{name} must be a time or time key")
      end
    end
  end
end
