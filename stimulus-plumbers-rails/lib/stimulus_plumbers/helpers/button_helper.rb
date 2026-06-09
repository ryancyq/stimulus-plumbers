# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module ButtonHelper
      def sp_button(content = nil, **kwargs, &block)
        button_renderer.render(content, **kwargs, &block)
      end

      def sp_button_group(...)
        Components::Button::Group.new(self).render(...)
      end

      private

      def button_renderer
        Components::Button.new(self)
      end
    end
  end
end
