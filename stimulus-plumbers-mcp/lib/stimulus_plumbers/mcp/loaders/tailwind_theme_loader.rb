# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    class TailwindThemeLoader
      def self.call
        theme = Themes::TailwindTheme.new

        Themes::Base::SCHEMA.each_with_object({}) do |(key, params), result|
          # Skip keys with no _classes method — calling resolve would trigger Logger.warn
          next unless theme.respond_to?(:"#{key}_classes", true)

          result[key] = {}
          result[key][:default] = theme.resolve(key)[:classes].to_s

          params.each do |param, meta|
            valid = meta[:validate]
            next unless valid.respond_to?(:to_a)

            valid.to_a.each do |val|
              classes = theme.resolve(key, param => val)[:classes].to_s
              result[key]["#{param}:#{val}"] = classes
            end
          end
        end
      end
    end
  end
end
