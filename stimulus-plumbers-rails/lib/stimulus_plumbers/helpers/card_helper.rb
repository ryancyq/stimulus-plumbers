# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module CardHelper
      def sp_card(title: nil, **html_options, &block)
        card_renderer.card(title: title, **html_options, &block)
      end

      def sp_card_section(title: nil, **html_options, &block)
        card_renderer.section(title: title, **html_options, &block)
      end

      private

      def card_renderer
        Components::Card::Renderer.new(self)
      end
    end
  end
end
