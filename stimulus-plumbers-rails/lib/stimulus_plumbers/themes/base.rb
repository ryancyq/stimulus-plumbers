# frozen_string_literal: true

require_relative "schema"

module StimulusPlumbers
  module Themes
    class Base
      SCHEMA = {
        **Schema::ACTION_LIST,
        **Schema::AVATAR,
        **Schema::BUTTON,
        **Schema::CALENDAR,
        **Schema::CARD,
        **Schema::COMBOBOX,
        **Schema::FORM,
        **Schema::LAYOUT
      }.freeze

      def name
        @name ||= self.class.name.demodulize.delete_suffix("Theme")
      end

      def avatar_colors
        {}
      end

      def avatar_color_range
        []
      end

      def attribute_names(component)
        SCHEMA.fetch(component, {}).keys
      end

      # Resolves presentational classes for a component slot.
      # Returns a Hash with :classes (String) and optionally :style (String).
      # Returns {} when no mapping exists for the given component.
      def resolve(component, **args)
        method_name = :"#{component}_classes"
        unless respond_to?(method_name, true)
          StimulusPlumbers::Logger.warn("#{self.class} has no classes method for component #{component.inspect}")
          return {}
        end

        send(method_name, **validate_args(component.to_sym, args))
      end

      private

      def validate_args(component, args)
        schema = SCHEMA.fetch(component, {})
        args.slice(*schema.keys).each_with_object({}) do |(key, value), result|
          result[key] = coerce_arg(component, key, value, schema[key])
        end
      end

      def coerce_arg(component, key, value, schema)
        return value unless schema

        range = range_for(schema)
        return value if range.empty? || range.include?(value)

        StimulusPlumbers::Logger.warn(
          "#{component}##{key} received unknown value #{value.inspect}. " \
          "Range: #{schema[:range].inspect}. Falling back to: #{schema[:default].inspect}"
        )
        schema[:default]
      end

      def range_for(schema)
        if schema[:range].is_a?(Symbol)
          respond_to?(schema[:range], true) ? send(schema[:range]) : []
        else
          schema[:range]
        end
      end
    end
  end
end
