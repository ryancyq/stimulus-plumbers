# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class ActionList
      class Section < Plumber::Base
        def render(title: nil, **kwargs, &block)
          render_section(title, **kwargs, &block)
        end

        private

        def render_section(title, **kwargs, &block)
          html_options = merge_html_options(
            theme.resolve(:action_list_section),
            kwargs
          )
          template.content_tag(:li, **html_options) do
            template.safe_join(
              [
                render_section_header(title),
                render_section_body(title, &block)
              ]
            )
          end
        end

        def render_section_header(title)
          return unless title.present?

          template.content_tag(:span, title, aria: { hidden: "true" })
        end

        def render_section_body(title, &block)
          html_options = {}
          html_options[:aria] = { label: title } if title.present?
          template.content_tag(:ul, template.capture(&block), html_options)
        end
      end
    end
  end
end
