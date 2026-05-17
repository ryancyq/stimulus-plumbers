# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    class Configuration
      def register(name, klass)
        raise ArgumentError, "#{klass} must be a subclass of Themes::Base" unless klass <= Base

        registry[name.to_sym] = klass
        self
      end

      def use(name_or_instance)
        @current = resolve(name_or_instance)
        self
      end

      def current
        @current ||= Base.new
      end

      def registry
        @registry ||= {}
      end

      private

      def resolve(value)
        return value if value.is_a?(Base)

        klass = registry[value.to_sym]
        raise ArgumentError, "Unknown theme #{value.inspect}. Registered: #{registry.keys.inspect}" unless klass

        klass.new
      end
    end
  end
end
