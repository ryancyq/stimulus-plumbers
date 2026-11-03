# frozen_string_literal: true

module StimulusPlumbers
  # A time key is HH:MM in 00:00–23:59.
  module Times
    KEY_PATTERN = %r{\A(\d{2}):(\d{2})\z}

    class << self
      # A time key, or a time's clock as given without seconds, as a time key; nil otherwise.
      def parse_key(value)
        return format("%<hour>02d:%<minute>02d", hour: value.hour, minute: value.min) if value.acts_like?(:time)

        match = KEY_PATTERN.match(value.to_s)
        value.to_s if match && match[1].to_i < 24 && match[2].to_i < 60
      end
    end
  end
end
