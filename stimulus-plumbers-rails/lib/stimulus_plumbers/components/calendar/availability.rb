# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar
      # Dates are Date objects, YYYY-MM-DD keys, or times read as their date in Time.zone.
      class Availability
        KEY_PATTERN = %r{\A\d{4}-\d{2}-\d{2}\z}

        attr_reader :min, :max, :disabled_dates, :disabled_weekdays, :disabled_months, :disabled_years

        class << self
          def date(value, name)
            return value.in_time_zone.to_date if value.acts_like?(:time)
            return value if value.is_a?(Date)

            key = value.to_s
            raise ArgumentError, "#{name} must be a date or date key" unless KEY_PATTERN.match?(key)

            parsed = Date.iso8601(key)
            raise ArgumentError, "#{name} must be a year 0001–9999" if parsed.year < 1

            parsed
          rescue Date::Error
            raise ArgumentError, "#{name} must be a date or date key"
          end
        end

        def initialize(
          min: nil,
          max: nil,
          disabled_dates: [],
          disabled_weekdays: [],
          disabled_months: [],
          disabled_years: []
        )
          @min               = min && self.class.date(min, :min)
          @max               = max && self.class.date(max, :max)
          raise ArgumentError, "min is after max" if @min && @max && @min > @max

          @disabled_dates    = disabled_dates.map { |value| self.class.date(value, :disabled_dates) }
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

        def validate_integers!(values, range, name)
          return values if values.all? { |value| value.is_a?(Integer) && range.cover?(value) }

          raise ArgumentError, "#{name} must be integers #{range.min}–#{range.max}"
        end
      end
    end
  end
end
