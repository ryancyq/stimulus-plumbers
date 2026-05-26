# frozen_string_literal: true

require "delegate"

module StimulusPlumbers
  module Themes
    module Icons
      class Registry < SimpleDelegator
        attr_reader :aliases

        def initialize(sources:, aliases: {})
          @sources = sources
          @aliases = aliases
          super(
            Hash.new do |h, key|
              resolved = aliases.fetch(key, key)
              value = nil
              sources.each { |s| break if (value = s.fetch(resolved)) }
              h[key] = value if value
              value
            end
          )
        end

        def key?(name)
          __getobj__.key?(name) ||
            aliases.key?(name) ||
            @sources.any? { |s| s.include?(aliases.fetch(name, name)) }
        end
        alias_method :include?, :key?
        alias_method :has_key?, :key?
        alias_method :member?, :key?
      end
    end
  end
end
