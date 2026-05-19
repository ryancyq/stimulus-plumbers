# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class ActionList < Plumber::Base
      def render(role: "list", **kwargs, &block)
        html_options = merge_html_options(
          { role: role, classes: theme.resolve(:action_list).fetch(:classes, "") },
          kwargs
        )
        template.content_tag(:ul, template.capture(&block), **html_options)
      end

      def section(title: nil, **kwargs, &block)
        ActionList::Section.new(template).render(title: title, **kwargs, &block)
      end

      def item(content = nil, **kwargs, &block)
        ActionList::Item.new(template).render(content, **kwargs, &block)
      end
    end
  end
end
