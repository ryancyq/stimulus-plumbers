# frozen_string_literal: true

require "delegate"

module StimulusPlumbers
  module Themes
    module Tailwind
      module Icons
        class Registry < SimpleDelegator
          attr_reader :aliases

          def initialize(aliases: {})
            @aliases = aliases
            super(
              Hash.new do |h, key|
                value = Custom.fetch(key) || Heroicon.fetch(aliases.fetch(key, key))
                h[key] = value if value
                value
              end)
          end

          def key?(name)
            __getobj__.key?(name) ||
              Custom.include?(name) ||
              aliases.key?(name) ||
              Heroicon.include?(name)
          end
          alias_method :include?, :key?
          alias_method :has_key?, :key?
          alias_method :member?, :key?
        end
      end
    end
  end
end
