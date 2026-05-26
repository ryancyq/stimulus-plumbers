# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module ActionListHelper
      def sp_action_list(...)
        action_list_renderer.render(...)
      end

      def sp_action_list_section(...)
        action_list_renderer.section(...)
      end

      def sp_action_list_item(content = nil, **kwargs, &block)
        action_list_renderer.item(content, **kwargs, &block)
      end

      private

      def action_list_renderer
        Components::ActionList.new(self)
      end
    end
  end
end
