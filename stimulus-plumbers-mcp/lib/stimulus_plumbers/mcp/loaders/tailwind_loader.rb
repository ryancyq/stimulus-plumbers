# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    class TailwindLoader
      class << self
        def call
          theme = Themes::TailwindTheme.new

          Themes::Base::SCHEMA.each_with_object({}) do |(key, params), result|
            # Skip keys with no _classes method — calling resolve would trigger Logger.warn
            next unless theme.respond_to?(:"#{key}_classes", true)

            result[key] = component_classes(theme, key, params)
          end
        end

        private

        def component_classes(theme, key, params)
          classes = { default: theme.resolve(key)[:classes].to_s }

          params.each do |param, meta|
            valid = meta[:validate]
            next unless valid.respond_to?(:to_a)

            valid.to_a.each { |val| classes["#{param}:#{val}"] = theme.resolve(key, param => val)[:classes].to_s }
          end

          classes
        end
      end
    end
  end
end
