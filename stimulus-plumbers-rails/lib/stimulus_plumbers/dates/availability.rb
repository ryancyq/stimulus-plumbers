# frozen_string_literal: true

module StimulusPlumbers
  module Dates
    # The dates a field offers. Dates are Date objects or date keys.
    class Availability
      OPTIONS = %i[min max disabled_dates disabled_weekdays disabled_months disabled_years].freeze

      attr_reader :min, :max, :disabled_dates, :disabled_weekdays, :disabled_months, :disabled_years

      def initialize(
        min: nil,
        max: nil,
        disabled_dates: [],
        disabled_weekdays: [],
        disabled_months: [],
        disabled_years: []
      )
        @min               = min && parse_date!(min, :min)
        @max               = max && parse_date!(max, :max)
        raise ArgumentError, "min is after max" if @min && @max && @min > @max

        @disabled_dates    = disabled_dates.map { |value| parse_date!(value, :disabled_dates) }
        @disabled_weekdays = validate_integers!(disabled_weekdays, 0..6, :disabled_weekdays)
        @disabled_months   = validate_integers!(disabled_months, 1..12, :disabled_months)
        @disabled_years    = validate_integers!(disabled_years, 1..9999, :disabled_years)
      end

      def disabled?(date)
        (min && date < min) || (max && date > max) || disabled_dates.include?(date) ||
          disabled_weekdays.include?(date.wday) || month_disabled?(date.year, date.month)
      end

      def month_disabled?(year, month)
        first = Date.new(year, month, 1)
        disabled_months.include?(month) || year_disabled?(year) ||
          (min && first.end_of_month < min) || (max && first > max)
      end

      def year_disabled?(year)
        disabled_years.include?(year) || (min && year < min.year) || (max && year > max.year)
      end

      private

      def parse_date!(value, name)
        Dates.parse_key(value) || raise(ArgumentError, "#{name} must be a date or date key")
      end

      def validate_integers!(values, range, name)
        return values if values.all? { |value| value.is_a?(Integer) && range.cover?(value) }

        raise ArgumentError, "#{name} must be integers #{range.min}–#{range.max}"
      end
    end
  end
end
