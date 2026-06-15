# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Card < Plumber::Base
      def render(variant: :tertiary, title_tag: :h2, **kwargs, &block)
        slots = Card::Slots.new
        yield slots if block_given?

        html_options = merge_html_options(theme.resolve(:card, variant: variant), kwargs)
        template.content_tag(:div, **html_options) do
          template.safe_join(
            [
              render_header(slots, title_tag),
              render_body(slots),
              render_action(slots)
            ]
          )
        end
      end

      private

      def render_header(slots, title_tag)
        icon  = slots.resolve(:icon) { |value| render_icon_slot(value) }
        title = slots.resolve(:title)
        return unless icon || title

        template.content_tag(:div, **merge_html_options(theme.resolve(:card_header))) do
          template.safe_join(
            [
              icon,
              (template.content_tag(title_tag, title, **merge_html_options(theme.resolve(:card_title))) if title)
            ]
          )
        end
      end

      def render_body(slots)
        content = slots.resolve(:body)
        return unless content

        template.content_tag(:div, **merge_html_options(theme.resolve(:card_body))) do
          content
        end
      end

      def render_icon_slot(value)
        return value unless value.is_a?(Symbol) || (value.is_a?(String) && !value.html_safe?)

        Components::Icon.new(template).render(
          name:    value,
          classes: theme.resolve(:card_icon).fetch(:classes, ""),
          aria:    { hidden: "true" }
        )
      end

      def render_action(slots)
        content = slots.resolve(:action)
        return unless content

        url = slots.options_for(:action)[:url]
        Components::Button.new(template).build(type: :ghost, variant: :tertiary) do |attrs|
          element = url.present? ? :a : :button
          extra   = url.present? ? { href: url } : { type: "button" }
          template.content_tag(element, **merge_html_options(attrs, extra, theme.resolve(:card_action))) do
            template.content_tag(:span, content)
          end
        end
      end
    end
  end
end
