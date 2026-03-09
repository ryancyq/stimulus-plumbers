# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Card
      class Renderer
        attr_reader :template, :theme

        def initialize(template, theme)
          @template = template
          @theme    = theme
        end

        def card(title: nil, **html_options, &block)
          classes = theme.resolve(:card).fetch(:classes, "")
          html_options[:class] = merge_class(classes, html_options[:class])

          template.content_tag(:div, **html_options) do
            template.safe_join(
              [
                (template.content_tag(:h2, title) if title.present?),
                template.capture(&block)
              ].compact
            )
          end
        end

        def section(title: nil, **html_options, &block)
          classes = theme.resolve(:card_section).fetch(:classes, "")
          html_options[:class] = merge_class(classes, html_options[:class])

          template.content_tag(:div, **html_options) do
            template.safe_join(
              [
                (template.content_tag(:h3, title) if title.present?),
                template.capture(&block)
              ].compact
            )
          end
        end

        private

        def merge_class(*classes)
          classes.select(&:present?).join(" ").presence
        end
      end
    end
  end
end
