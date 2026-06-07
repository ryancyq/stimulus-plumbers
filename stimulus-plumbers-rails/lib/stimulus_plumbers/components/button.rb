# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Button < Plumber::Base
      def render(content = nil, icon_leading: nil, icon_trailing: nil, **kwargs, &block)
        build(**kwargs) do |html_options|
          template.content_tag(:button, type: "button", **html_options) do
            build_layout(icon_leading: icon_leading, icon_trailing: icon_trailing) do
              build_button(content, &block)
            end
          end
        end
      end

      def build(type: :default, variant: :primary, size: :md, **kwargs, &block)
        html_options = merge_html_options(
          theme.resolve(:button, type: type, variant: variant, size: size),
          kwargs
        )
        template.capture(html_options, &block)
      end

      private

      def build_button(content, &block)
        if block_given?
          template.content_tag(:span, template.capture(&block))
        elsif content
          template.content_tag(:span, content)
        end
      end

      def build_layout(icon_leading: nil, icon_trailing: nil, &block)
        template.safe_join(
          [
            render_icon(icon_leading, theme: :button_icon),
            template.capture(&block),
            render_icon(icon_trailing, theme: :button_icon)
          ]
        )
      end
    end
  end
end
