# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module CardHelper
      def sp_card(**html_options, &block)
        card_renderer.render(**html_options, &block)
      end

      def sp_card_section(**html_options, &block)
        card_renderer.section(**html_options, &block)
      end

      private

      def card_renderer
        Components::Card.new(self)
      end
    end
  end
end
