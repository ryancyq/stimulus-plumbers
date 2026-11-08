# frozen_string_literal: true

require "active_support/concern"

module StimulusPlumbers
  module Plumber
    module Options
      # An option that takes one of a fixed set of values.
      module Choice
        extend ActiveSupport::Concern

        private

        def validate_choice!(value, choices, name)
          normalized = value.to_sym if value.respond_to?(:to_sym)
          return normalized if choices.include?(normalized)

          raise ArgumentError, "#{name} must be one of: #{choices.join(", ")}"
        end
      end
    end
  end
end
