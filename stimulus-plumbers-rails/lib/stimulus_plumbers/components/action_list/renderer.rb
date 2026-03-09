# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module ActionList
      class Renderer
        attr_reader :template, :theme

        def initialize(template, theme)
          @template = template
          @theme    = theme
        end

        def list(**html_options, &block)
          classes = theme.resolve(:action_list).fetch(:classes, "")
          html_options[:class] = merge_class(classes, html_options[:class])
          template.content_tag(:div, template.capture(&block), **html_options)
        end

        def section(title: nil, **html_options, &block)
          template.content_tag(:div, **html_options) do
            template.safe_join(
              [
                (template.content_tag(:p, title) if title.present?),
                template.content_tag(:ul, template.capture(&block))
              ].compact
            )
          end
        end

        def item(content = nil, url: nil, external: false, active: false, **html_options, &block)
          content = template.capture(&block) if block_given?
          classes = theme.resolve(:action_list_item, active: active).fetch(:classes, "")
          html_options[:class] = merge_class(classes, html_options[:class])

          inner = if url
                    html_options[:target] = "_blank" if external
                    template.content_tag(:a, content, href: url, **html_options)
                  else
                    html_options[:type] ||= "button"
                    template.content_tag(:button, content, **html_options)
                  end

          template.content_tag(:li, inner)
        end

        private

        def merge_class(*classes)
          classes.select(&:present?).join(" ").presence
        end
      end
    end
  end
end
