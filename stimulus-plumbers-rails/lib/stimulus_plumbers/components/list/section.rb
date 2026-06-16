# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class List
      class Section < Plumber::Base
        def initialize(template, heading_level: nil)
          super(template)
          @heading_level = heading_level
        end

        def render(title: nil, description: nil, **kwargs, &block)
          html_options = merge_html_options(theme.resolve(:list_section), kwargs)
          template.content_tag(:li, **html_options) do
            template.safe_join(
              [
                render_section_header(title, description),
                render_section_body(title, &block)
              ]
            )
          end
        end

        def section(...)
          List::Section.new(template, heading_level: (@heading_level || 0) + 1).render(...)
        end

        def item(content = nil, **kwargs, &block)
          List::Item.new(template).render(content, **kwargs, &block)
        end

        private

        def render_section_header(title, description)
          return unless title.present? || description.present?

          template.safe_join(
            [
              render_section_title(title),
              (if description.present?
                 template.content_tag(
                   :span,
                   description,
                   **merge_html_options(theme.resolve(:list_section_description))
                 )
               end)
            ]
          )
        end

        def render_section_title(title)
          return unless title.present?

          if @heading_level
            tag = :"h#{[@heading_level, 6].min}"
            template.content_tag(tag, title, **merge_html_options(theme.resolve(:list_section_title)))
          else
            template.content_tag(
              :span,
              title,
              **merge_html_options(theme.resolve(:list_section_title), { aria: { hidden: "true" } })
            )
          end
        end

        def render_section_body(title, &block)
          opts = title.present? ? { aria: { label: title } } : {}
          template.content_tag(:ul, template.capture(self, &block), opts)
        end
      end
    end
  end
end
