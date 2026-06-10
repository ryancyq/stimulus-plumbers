# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Link < Plumber::Base
      def render(content = nil, url:, icon_leading: nil, icon_trailing: nil, **kwargs, &block)
        icon_trailing ||= "external-link" if kwargs[:target] == "_blank"

        slots = Link::Slots.new
        slots.with_icon_leading(icon_leading) if icon_leading
        slots.with_icon_trailing(icon_trailing) if icon_trailing

        render_link(url: url, **kwargs) do
          build_layout(slots) do
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

      def build_layout(slots, &block)
        template.safe_join(
          [
            render_icon_slot(slots, :icon_leading),
            template.capture(&block),
            render_icon_slot(slots, :icon_trailing)
          ]
        )
      end

      def render_icon_slot(slots, name)
        slots.resolve(name) do |value|
          next value unless Components::Icon.icon_name?(value)

          Components::Icon.new(template).render(
            name:    value,
            classes: theme.resolve(:link_icon).fetch(:classes, ""),
            aria:    { hidden: "true" }
          )
        end
      end

      def build_content(content, &block)
        if block_given?
          template.content_tag(:span, template.capture(&block))
        elsif content
          template.content_tag(:span, content)
        end
      end
    end
  end
end
