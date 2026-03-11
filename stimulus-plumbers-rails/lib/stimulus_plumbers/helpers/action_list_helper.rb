# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module ActionListHelper
      def sp_action_list(**html_options, &block)
        action_list_renderer.list(**html_options, &block)
      end

      def sp_action_list_section(title: nil, **html_options, &block)
        action_list_renderer.section(title: title, **html_options, &block)
      end

      def sp_action_list_item(content = nil, url: nil, external: false, active: false, **html_options, &block)
        action_list_renderer.item(content, url: url, external: external, active: active, **html_options, &block)
      end

      private

      def action_list_renderer
        Components::ActionList::Renderer.new(self)
      end
    end
  end
end
