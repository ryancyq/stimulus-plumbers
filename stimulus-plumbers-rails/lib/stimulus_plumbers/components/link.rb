# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Link < Plumber::Base
      def render(content = nil, url:, icon_leading: nil, icon_trailing: nil, **kwargs, &block)
        render_link(url: url, **kwargs) do
          build_layout(icon_leading: icon_leading, icon_trailing: icon_trailing) do
            build_content(content, &block)
          end
        end
      end

      private

      def render_link(url:, target: nil, variant: :default, **kwargs, &block)
        html_options = merge_html_options(
          theme.resolve(:link, variant: variant),
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
        block_given? ? template.capture(&block) : content
      end

      def render_icon(name)
        super(name, theme_key: :link_icon)
      end
    end
  end
end
