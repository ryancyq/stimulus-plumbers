# frozen_string_literal: true

require_relative "themes/base"
require_relative "themes/tailwind_theme"

module StimulusPlumbers
  class Configuration
    DEFAULT_LOG_FORMATTER  = ->(message) { "[StimulusPlumbers] #{message}" }
    THEME_KLASS_FORMATTER  = ->(type) { "StimulusPlumbers::Themes::#{type.to_s.classify}Theme" }

    def theme
      @theme ||= build_theme(:tailwind)
    end

    def theme=(value)
      @theme = build_theme(value)
    end

    def log_formatter
      @log_formatter ||= DEFAULT_LOG_FORMATTER
    end

    def log_formatter=(callable)
      raise ArgumentError, "log_formatter must respond to #call" unless callable.respond_to?(:call)

      @log_formatter = callable
    end

    private

    def build_theme(type)
      return type if type.is_a?(Themes::Base)

      klass_name = THEME_KLASS_FORMATTER.call(type)
      klass_name.safe_constantize&.new or
        raise ArgumentError, "Unknown theme #{type.inspect}: #{klass_name} is not defined."
    end
  end
end
