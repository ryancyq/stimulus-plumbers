# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module ButtonHelper
      def sp_button(content = nil, url: nil, external: false, variant: :primary, size: :md, **html_options, &block)
        button_renderer.button(
          content,
          url: url, external: external, variant: variant, size: size, **html_options,
          &block
        )
      end

      def sp_button_group(alignment: :left, direction: :row, **html_options, &block)
        button_renderer.group(alignment: alignment, direction: direction, **html_options, &block)
      end

      private

      def button_renderer
        Components::Button::Renderer.new(self)
      end
    end
  end
end
