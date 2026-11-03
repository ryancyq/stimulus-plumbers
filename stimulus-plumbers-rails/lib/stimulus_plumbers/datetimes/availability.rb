# frozen_string_literal: true

module StimulusPlumbers
  module Datetimes
    # The date-times a field offers: `min` and `max` moments as times or date-time keys, the
    # Dates::Availability `disabled_*` rules, and `time`, the Times::Availability options for every day.
    class Availability
      DATE_OPTIONS = (Dates::Availability::OPTIONS - %i[min max]).freeze
      OPTIONS      = [:min, :max, *DATE_OPTIONS, :time].freeze

      attr_reader :min, :max, :dates, :time

      def initialize(min: nil, max: nil, time: {}, **dates)
        @min = min && key!(min, :min)
        @max = max && key!(max, :max)
        raise ArgumentError, "min is after max" if @min && @max && @min > @max

        @dates = Dates::Availability.new(**dates)
        @time  = time!(time)
        raise ArgumentError, "min and max leave no time in the daily window" if no_time_between?
      end

      # `key` is a date-time key.
      def disabled?(key)
        (min && key < min) || (max && key > max) || dates.disabled?(date_of(key)) || time.disabled?(key[11, 5])
      end

      # The Times::Availability on a date: the daily window, cut off at `min` and `max` on their own dates.
      def day_availability(date)
        prefix = "#{date.iso8601}T"
        time.narrow(from: (min[11, 5] if min&.start_with?(prefix)), to: (max[11, 5] if max&.start_with?(prefix)))
      end

      # The Dates::Availability: the dates of `min` and `max`, and those dates when no time is left on them.
      def date_availability
        rules = DATE_OPTIONS.to_h { |name| [name, dates.public_send(name)] }
        Dates::Availability.new(
          min: min && date_of(min),
          max: max && date_of(max),
          **rules.merge(disabled_dates: dates.disabled_dates | empty_dates)
        )
      end

      private

      def date_of(key)
        Date.iso8601(key[0, 10])
      end

      def empty_dates
        [min, max].compact.map { |key| date_of(key) }.uniq.select { |date| no_time_on?(date) }
      end

      # `min` and `max` fall on the same or neighbouring dates, and neither date has a time left.
      def no_time_between?
        return false unless min && max

        first = date_of(min)
        last  = date_of(max)
        last - first <= 1 && [first, last].all? { |date| no_time_on?(date) }
      end

      # No time is left on a date once the daily window is cut off at `min` and `max`.
      def no_time_on?(date)
        day_availability(date).empty?
      end

      def key!(value, name)
        Datetimes.parse_key(value) || raise(ArgumentError, "#{name} must be a time or date-time key")
      end

      def time!(options)
        Times::Availability.new(**options)
      rescue ArgumentError => e
        raise ArgumentError, "time.#{e.message}"
      end
    end
  end
end
