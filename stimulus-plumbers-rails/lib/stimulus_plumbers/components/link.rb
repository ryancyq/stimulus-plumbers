# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Link < Plumber::Base
      def render(content = nil, url:, icon_leading: nil, icon_trailing: nil, **kwargs, &block)
        icon_trailing ||= "external-link" if kwargs[:target] == "_blank"
        render_link(url: url, **kwargs) do
          build_layout(icon_leading: icon_leading, icon_trailing: icon_trailing) do
            build_content(content, &block)
          end
        end
      end

      private

      def render_link(url:, target: nil, type: :default, variant: :default, **kwargs, &block)
        html_options = merge_html_options(
          theme.resolve(:link, type: type, variant: variant),
          kwargs
        )
        template.content_tag(:a, href: url, target: target, **html_options) do
          template.capture(&block)
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

      def build_content(content, &block)
        if block_given?
          template.content_tag(:span, template.capture(&block))
        elsif content
          template.content_tag(:span, content)
        end
      end

      def render_icon(name)
        super(name, theme_key: :link_icon)
      end
    end
  end
end
