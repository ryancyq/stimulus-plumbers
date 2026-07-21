# frozen_string_literal: true

module StimulusPlumbers
  module Plumber
    # Sibling of Slots for block DSLs whose payload is configuration, not content.
    # Slots captures blocks through the view; Config only stores values, and holds
    # the template to pass on to renderers.
    #
    # The store is private. Slots publishes `resolve` because its payload is uniform
    # content a renderer reads generically; a Config's settings are typed, so each
    # subclass exposes its own named readers instead.
    class Config
      attr_reader :template

      def initialize(template = nil)
        @template = template
        @config = {}
      end

      private

      # Returns nil so a subclass's DSL method reads as a command, not a value.
      def configure(name, value)
        @config[name] = value
        nil
      end

      def config(name)
        @config[name]
      end

      def configured?(name)
        @config.key?(name)
      end
    end
  end
end
