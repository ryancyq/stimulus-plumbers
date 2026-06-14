# frozen_string_literal: true

module StimulusPlumbers
  module Logger
    LEVELS = %i[debug info warn error].freeze

    LEVELS.each do |level|
      define_method(level) do |message|
        tagged = StimulusPlumbers.config.log_formatter.call(message)
        if defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger
          Rails.logger.public_send(level, tagged)
        else
          # Kernel.warn, not bare `warn` which would recurse into this module's own warn.
          Kernel.warn(tagged)
        end
      end
    end

    module_function(*LEVELS)
  end
end
