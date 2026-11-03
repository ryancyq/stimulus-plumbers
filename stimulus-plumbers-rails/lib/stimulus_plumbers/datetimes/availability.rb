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
        @min = min && parse_key!(min, :min)
        @max = max && parse_key!(max, :max)
        raise ArgumentError, "min is after max" if @min && @max && @min > @max

        @dates = Dates::Availability.new(**dates)
        @time  = parse_time!(time)
        raise ArgumentError, "min and max leave no time in the daily window" if no_time_between?
      end

      # `key` is a date-time key.
      def disabled?(key)
        (min && key < min) || (max && key > max) || dates.disabled?(Datetimes.date_of(key)) || time.disabled?(key[11, 5])
      end

      # The Times::Availability on a date: the daily window's ranges, trimmed at `min` and `max` on their own dates.
      def day_availability(date)
        prefix = "#{date.iso8601}T"
        time.trim(from: (min[11, 5] if min&.start_with?(prefix)), to: (max[11, 5] if max&.start_with?(prefix)))
      end

      # The Dates::Availability: the dates of `min` and `max`, and those dates when no time is left on them.
      def date_availability
        rules = DATE_OPTIONS.to_h { |name| [name, dates.public_send(name)] }
        Dates::Availability.new(
          min: min && Datetimes.date_of(min),
          max: max && Datetimes.date_of(max),
          **rules.merge(disabled_dates: dates.disabled_dates | empty_dates)
        )
      end

      private

      def empty_dates
        [min, max].compact.map { |key| Datetimes.date_of(key) }.uniq.select { |date| no_time_on?(date) }
      end

      # `min` and `max` fall on the same or neighbouring dates, and neither date has a time left.
      def no_time_between?
        return false unless min && max

        first = Datetimes.date_of(min)
        last  = Datetimes.date_of(max)
        last - first <= 1 && [first, last].all? { |date| no_time_on?(date) }
      end

      # No time is left on a date once the daily window is trimmed at `min` and `max`.
      def no_time_on?(date)
        day_availability(date).empty?
      end

      def parse_key!(value, name)
        Datetimes.parse_key(value) || raise(ArgumentError, "#{name} must be a time or date-time key")
      end

      def parse_time!(options)
        Times::Availability.new(**options)
      rescue ArgumentError => e
        raise ArgumentError, "time.#{e.message}"
      end
    end
  end
end
