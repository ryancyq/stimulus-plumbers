# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module ButtonHelper
      def sp_button(content = nil, **kwargs, &block)
        Components::Button.new(self).render(content, **kwargs, &block)
      end

      def sp_button_group(...)
        Components::Button::Group.new(self).render(...)
      end
    end
  end
end
