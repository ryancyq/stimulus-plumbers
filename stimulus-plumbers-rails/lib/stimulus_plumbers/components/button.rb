# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Button < Plumber::Base
      def render(content = nil, icon_leading: nil, icon_trailing: nil, **kwargs, &block)
        render_button(**kwargs) do
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

      def render_button(url: nil, external: false, target: nil, variant: :primary, size: :md, **kwargs, &block)
        html_options = merge_html_options(
          { classes: theme.resolve(:button, variant: variant, size: size).fetch(:classes, "") },
          kwargs
        )
        if url.present?
          target = "_blank" if external
          template.content_tag(:a, href: url, target: target, **html_options) do
            template.capture(&block)
          end
        else
          template.content_tag(:button, type: "button", **html_options) do
            template.capture(&block)
          end
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
