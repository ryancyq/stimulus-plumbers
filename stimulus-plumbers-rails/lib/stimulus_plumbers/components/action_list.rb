# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class ActionList < Plumber::Base
      def render(...)
        render_list(...)
      end

      def section(...)
        ActionList::Section.new(template).render(...)
      end

      def item(content = nil, **kwargs, &block)
        ActionList::Item.new(template).render(content, **kwargs, &block)
      end

      private

      def render_list(role: "list", **kwargs, &block)
        html_options = merge_html_options(
          theme.resolve(:action_list),
          kwargs,
          { role: role }
        )
        template.content_tag(:ul, template.capture(self, &block), **html_options)
      end
    end
  end
end
