# frozen_string_literal: true

require_relative "themes/base"
require_relative "themes/configuration"

module StimulusPlumbers
  class Configuration
    DEFAULT_LOG_FORMATTER = ->(message) { "[StimulusPlumbers] #{message}" }

    def theme
      @theme ||= Themes::Configuration.new
    end

    def log_formatter
      @log_formatter ||= DEFAULT_LOG_FORMATTER
    end

    def log_formatter=(callable)
      raise ArgumentError, "log_formatter must respond to #call" unless callable.respond_to?(:call)

      @log_formatter = callable
    end
  end
end
