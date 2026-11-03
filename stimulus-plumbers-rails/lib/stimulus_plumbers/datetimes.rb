# frozen_string_literal: true

module StimulusPlumbers
  # A date-time key is YYYY-MM-DDTHH:MM: a date key and a time key on the wall clock.
  module Datetimes
    KEY_PATTERN = %r{\A(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2})\z}

    class << self
      def date_of(key)
        Date.iso8601(key[0, 10])
      end

      # A date-time key, or a time in Time.zone, as a date-time key without seconds; nil otherwise.
      def parse_key(value)
        return value.in_time_zone.strftime("%Y-%m-%dT%H:%M") if value.acts_like?(:time)

        match = KEY_PATTERN.match(value.to_s)
        value.to_s if match && Dates.parse_key(match[1]) && Times.parse_key(match[2])
      end
    end
  end
end
