# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class List < Plumber::Base
      def render(...)
        render_list(...)
      end

      def section(...)
        List::Section.new(template, heading_level: @heading_level).render(...)
      end

      def item(content = nil, **kwargs, &block)
        List::Item.new(template).render(content, **kwargs, &block)
      end

      private

      def render_list(role: "list", heading_level: nil, **kwargs, &block)
        @heading_level = heading_level
        html_options = merge_html_options(
          theme.resolve(:list),
          kwargs,
          { role: role }
        )
        template.content_tag(:ul, template.capture(self, &block), **html_options)
      end
    end
  end
end
