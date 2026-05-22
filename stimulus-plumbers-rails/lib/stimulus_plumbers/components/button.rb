# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Button < Plumber::Base
      def render(content = nil, **kwargs, &block)
        url     = kwargs.delete(:url)
        badge   = kwargs.delete(:badge) { false }
        button  = build_styled_button(content, **kwargs, &block)
        button  = render_button(button[:inner], url: url, **button[:html_options])
        badge ? wrap_with_badge(button, badge) : button
      end

      def group(alignment: :left, direction: :row, **kwargs, &block)
        Button::Group.new(template).render(alignment: alignment, direction: direction, **kwargs, &block)
      end

      private

      def build_styled_button(content, **kwargs, &block)
        external = kwargs.delete(:external) { false }
        variant  = kwargs.delete(:variant) { :primary }
        size     = kwargs.delete(:size) { :md }
        content  = template.capture(&block) if block_given?
        inner    = build_button(content, kwargs)
        html_options = merge_html_options(
          { classes: theme.resolve(:button, variant: variant, size: size).fetch(:classes, "") },
          kwargs
        )
        { inner: inner, html_options: html_options.merge(external: external) }
      end

      def build_button(content, kwargs)
        icon_leading  = kwargs.delete(:icon_leading)
        icon_trailing = kwargs.delete(:icon_trailing)
        template.safe_join(
          [
            icon_leading.respond_to?(:call) ? icon_leading.call : render_icon(icon_leading),
            content,
            icon_trailing.respond_to?(:call) ? icon_trailing.call : render_icon(icon_trailing)
          ]
        )
      end

      def render_button(inner, url:, external:, **html_options)
        if url
          html_options[:target] = "_blank" if external
          template.content_tag(:a, inner, href: url, **html_options)
        else
          html_options[:type] ||= "button"
          template.content_tag(:button, inner, **html_options)
        end
      end

      def render_icon(name)
        return unless name

        Icon.new(template).render(
          name:    name,
          classes: theme.resolve(:button_icon).fetch(:classes, "")
        )
      end

      def wrap_with_badge(button, badge)
        is_count = badge != true
        label = badge_label(badge, is_count)
        badge_classes = theme.resolve(:button_badge, count: is_count).fetch(:classes, "")
        badge_span = template.content_tag(:span, label, "aria-hidden": "true", class: badge_classes)
        template.content_tag(:span, template.safe_join([button, badge_span]), class: "relative inline-flex")
      end

      def badge_label(badge, is_count)
        return nil unless is_count

        badge.to_i > 9 ? "9+" : badge.to_s
      end
    end
  end
end
