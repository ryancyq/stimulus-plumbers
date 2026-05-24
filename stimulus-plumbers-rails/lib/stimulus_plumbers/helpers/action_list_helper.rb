# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module ActionListHelper
      def sp_action_list(**html_options, &block)
        action_list_renderer.render(**html_options, &block)
      end

      def sp_action_list_section(**html_options, &block)
        action_list_renderer.section(**html_options, &block)
      end

      def sp_action_list_item(content = nil, **html_options, &block)
        action_list_renderer.item(content, **html_options, &block)
      end

      private

      def action_list_renderer
        Components::ActionList.new(self)
      end
    end
  end
end
