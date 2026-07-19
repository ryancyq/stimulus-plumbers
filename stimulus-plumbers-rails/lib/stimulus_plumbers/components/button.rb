# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Button < Plumber::Base
      include IconLayout

      def render(content = nil, icon_leading: nil, icon_trailing: nil, **kwargs, &block)
        slots = Button::Slots.new(template)
        slots.with_icon_leading(icon_leading) if icon_leading
        slots.with_icon_trailing(icon_trailing) if icon_trailing

        build(**kwargs) do |html_options|
          template.content_tag(:button, type: "button", **html_options) do
            build_layout(slots) do
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
    end
  end
end
