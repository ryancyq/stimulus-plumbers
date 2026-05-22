# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Button < Plumber::Base
      def render(content = nil, **kwargs, &block)
        render_button_with_layout(**kwargs) do |opts|
          render_button(**opts) { build_button(content, &block) }
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

      def render_button_with_layout(icon_leading: nil, icon_trailing: nil, **kwargs, &block)
        template.safe_join(
          [
            icon_leading.respond_to?(:call) ? icon_leading.call : render_icon(icon_leading),
            template.capture(kwargs, &block),
            icon_trailing.respond_to?(:call) ? icon_trailing.call : render_icon(icon_trailing)
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
