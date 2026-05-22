# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class ActionList
      class Section < Plumber::Base
        def render(...)
          render_section(...)
        end

        private

        def render_section(title: nil, **html_options, &block)
          template.content_tag(:li, **html_options) do
            ul_opts = {}
            ul_opts[:aria] = { label: title } if title.present?
            template.safe_join(
              [
                (template.content_tag(:span, title, aria: { hidden: "true" }) if title.present?),
                template.content_tag(:ul, template.capture(&block), **ul_opts)
              ]
            )
          end
        end
      end
    end
  end
end
