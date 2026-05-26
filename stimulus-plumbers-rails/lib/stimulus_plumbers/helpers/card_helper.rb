# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module CardHelper
      def sp_card(...)
        card_renderer.render(...)
      end

      def sp_card_section(...)
        card_renderer.section(...)
      end

      private

      def card_renderer
        Components::Card.new(self)
      end
    end
  end
end
