# frozen_string_literal: true

require "active_support/concern"

module StimulusPlumbers
  module Plumber
    module IconRenderer
      extend ActiveSupport::Concern

      private

      def render_icon(icon_name, theme:)
        return unless icon_name
        return template.capture(&icon_name) if icon_name.respond_to?(:call)

        Components::Icon.new(template).render(
          name:    icon_name,
          classes: self.theme.resolve(theme).fetch(:classes, ""),
          aria:    { hidden: "true" }
        )
      end
    end
  end
end
