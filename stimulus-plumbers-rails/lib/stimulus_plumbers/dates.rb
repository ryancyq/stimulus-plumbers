# frozen_string_literal: true

module StimulusPlumbers
  # A date key is YYYY-MM-DD in the years 0001–9999.
  module Dates
    KEY_PATTERN = %r{\A\d{4}-\d{2}-\d{2}\z}

    class << self
      # A Date, a date key, or a time as its date in Time.zone; nil otherwise.
      def parse_key(value)
        return value.in_time_zone.to_date if value.acts_like?(:time)
        return value if value.is_a?(Date)
        return unless KEY_PATTERN.match?(value.to_s)

        date = Date.iso8601(value.to_s)
        date if date.year >= 1
      rescue Date::Error
        nil
      end
    end
  end
end
