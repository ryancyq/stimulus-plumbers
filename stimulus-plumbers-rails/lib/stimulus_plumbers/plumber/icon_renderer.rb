# frozen_string_literal: true

require "active_support/concern"

module StimulusPlumbers
  module Plumber
    module IconRenderer
      extend ActiveSupport::Concern

      private

      def render_icon(name, theme_key:)
        return unless name

        Components::Icon.new(template).render(
          name:    name,
          classes: theme.resolve(theme_key).fetch(:classes, ""),
          aria:    { hidden: "true" }
        )
      end
    end
  end
end
