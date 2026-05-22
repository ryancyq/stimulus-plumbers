# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Button < Plumber::Base
      def render(content = nil, **kwargs, &block)
        url      = kwargs.delete(:url)
        external = kwargs.delete(:external) { false }
        variant  = kwargs.delete(:variant) { :primary }
        size     = kwargs.delete(:size) { :md }
        content      = template.capture(&block) if block_given?
        inner        = build_button(content, kwargs)
        html_options = merge_html_options(
          { classes: theme.resolve(:button, variant: variant, size: size).fetch(:classes, "") },
          kwargs
        )
        render_button(inner, url: url, external: external, **html_options)
      end

      def group(alignment: :left, direction: :row, **kwargs, &block)
        Button::Group.new(template).render(alignment: alignment, direction: direction, **kwargs, &block)
      end

      private

      def build_button(content, kwargs)
        icon_leading  = kwargs.delete(:icon_leading)
        icon_trailing = kwargs.delete(:icon_trailing)
        template.safe_join(
          [
            icon_leading.respond_to?(:call) ? icon_leading.call : render_icon(icon_leading),
            content,
            icon_trailing.respond_to?(:call) ? icon_trailing.call : render_icon(icon_trailing)
          ]
        )
      end

      def render_button(inner, url:, external:, **html_options)
        if url
          html_options[:target] = "_blank" if external
          template.content_tag(:a, inner, href: url, **html_options)
        else
          html_options[:type] ||= "button"
          template.content_tag(:button, inner, **html_options)
        end
      end

      def render_icon(name)
        return unless name

        Icon.new(template).render(
          name:    name,
          classes: theme.resolve(:button_icon).fetch(:classes, "")
        )
      end
    end
  end
end
