# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module ButtonHelper
      def sp_button(content = nil, **html_options, &block)
        button_renderer.render(content, **html_options, &block)
      end

      def sp_button_group(**html_options, &block)
        button_renderer.group(**html_options, &block)
      end

      private

      def button_renderer
        Components::Button.new(self)
      end
    end
  end
end
