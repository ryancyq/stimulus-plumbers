# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Button
      class Renderer
        attr_reader :template, :theme

        def initialize(template, theme)
          @template = template
          @theme    = theme
        end

        def button(content = nil, url: nil, external: false, variant: :primary, size: :md, **html_options, &block)
          content = template.capture(&block) if block_given?
          classes = theme.resolve(:button, variant: variant, size: size).fetch(:classes, "")
          html_options[:class] = merge_class(classes, html_options[:class])

          if url
            html_options[:target] = "_blank" if external
            template.content_tag(:a, content, href: url, **html_options)
          else
            html_options[:type] ||= "button"
            template.content_tag(:button, content, **html_options)
          end
        end

        def group(alignment: :left, direction: :row, **html_options, &block)
          classes = theme.resolve(:button_group, alignment: alignment, direction: direction).fetch(:classes, "")
          html_options[:class] = merge_class(classes, html_options[:class])
          template.content_tag(:div, template.capture(&block), **html_options)
        end

        private

        def merge_class(*classes)
          classes.select(&:present?).join(" ").presence
        end
      end
    end
  end
end
