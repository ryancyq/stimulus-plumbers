# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Button < Plumber::Base
      def render(content = nil, icon_leading: nil, icon_trailing: nil, **kwargs, &block)
        icon_trailing ||= "external-link" if kwargs[:url].present? && kwargs[:target] == "_blank"
        render_button_or_link(**kwargs) do
          build_layout(icon_leading: icon_leading, icon_trailing: icon_trailing) do
            build_button(content, &block)
          end
        end
      end

      def group(...)
        Button::Group.new(template).render(...)
      end

      private

      def build_button(content, &block)
        if block_given?
          template.capture(&block)
        else
          content
        end
      end

      def build_layout(icon_leading: nil, icon_trailing: nil, &block)
        template.safe_join(
          [
            icon_leading.respond_to?(:call) ? template.capture(&icon_leading) : render_icon(icon_leading),
            template.capture(&block),
            icon_trailing.respond_to?(:call) ? template.capture(&icon_trailing) : render_icon(icon_trailing)
          ]
        )
      end

      def render_button_or_link(url: nil, **kwargs, &block)
        if url.present?
          render_link(url: url, **kwargs, &block)
        else
          render_button(**kwargs, &block)
        end
      end

      def render_button(type: :primary, variant: :default, size: :md, **kwargs, &block)
        html_options = merge_html_options(
          theme.resolve(:button, type: type, variant: variant, size: size),
          kwargs
        )

        template.content_tag(:button, type: "button", **html_options) do
          template.capture(&block)
        end
      end

      def render_link(url:, target: nil, variant: :default, size: :md, **kwargs, &block)
        html_options = merge_html_options(
          theme.resolve(:button_link, variant: variant, size: size),
          kwargs
        )
        template.content_tag(:a, href: url, target: target, **html_options) do
          template.capture(&block)
        end
      end

      def render_icon(name)
        super(name, theme_key: :button_icon)
      end
    end
  end
end
