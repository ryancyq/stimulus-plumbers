# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Button < Plumber::Base
      def render(content = nil, icon_leading: nil, icon_trailing: nil, **kwargs, &block)
        build(**kwargs) do |attrs|
          template.content_tag(:button, type: "button", **attrs) do
            build_layout(icon_leading: icon_leading, icon_trailing: icon_trailing) do
              build_button(content, &block)
            end
          end
        end
      end

      def build(type: :default, variant: :primary, size: :md, **kwargs, &block)
        attrs = merge_html_options(
          theme.resolve(:button, type: type, variant: variant, size: size),
          kwargs
        )
        template.capture(attrs, &block)
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
            icon_leading.respond_to?(:call) ? template.capture(&icon_leading) : render_icon(icon_leading),
            template.capture(&block),
            icon_trailing.respond_to?(:call) ? template.capture(&icon_trailing) : render_icon(icon_trailing)
          ]
        )
      end

      def render_icon(name)
        super(name, theme_key: :button_icon)
      end
    end
  end
end
