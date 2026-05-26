# frozen_string_literal: true

require_relative "schema"
require_relative "../plumber/dispatcher"

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
        **Schema::ICON,
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

      def icons
        {}
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

        send(method_name, **validate(component.to_sym, args))
      end

      private

      def validate(component, args)
        schema = SCHEMA.fetch(component, {})
        args.slice(*schema.keys).each_with_object({}) do |(key, value), result|
          result[key] = cast(component, key, value, schema[key])
        end
      end

      def cast(component, key, value, schema)
        return value unless schema
        return value if value.nil? || valid?(schema[:validate], value)

        StimulusPlumbers::Logger.warn(
          "#{component}##{key} received unknown value #{value.inspect}. " \
          "Validator: #{schema[:validate].inspect}. Falling back to: #{schema[:default].inspect}"
        )
        schema[:default]
      end

      def valid?(validator, value)
        return true if validator.nil?

        if validator.respond_to?(:include?)
          validator.include?(value)
        else
          result = Plumber::Dispatcher.build(validator, value).call(self)
          result.respond_to?(:include?) ? result.include?(value) : result
        end
      end
    end
  end
end
