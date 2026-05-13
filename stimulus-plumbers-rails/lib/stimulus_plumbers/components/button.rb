# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Button < Plumber::Base
      def render(content = nil, url: nil, external: false, variant: :primary, size: :md, **kwargs, &block)
        content      = template.capture(&block) if block_given?
        html_options = merge_html_options(
          { classes: theme.resolve(:button, variant: variant, size: size).fetch(:classes, "") },
          kwargs
        )

        if url
          html_options[:target] = "_blank" if external
          template.content_tag(:a, content, href: url, **html_options)
        else
          html_options[:type] ||= "button"
          template.content_tag(:button, content, **html_options)
        end
      end

      def group(alignment: :left, direction: :row, **kwargs, &block)
        Button::Group.new(template).render(alignment: alignment, direction: direction, **kwargs, &block)
      end
    end
  end
end
