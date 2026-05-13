# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class ActionList
      class Section < Plumber::Base
        def render(title: nil, **kwargs, &block)
          html_options = merge_html_options(kwargs)
          template.content_tag(:div, **html_options) do
            template.safe_join(
              [
                (template.content_tag(:p, title) if title.present?),
                template.content_tag(:ul, template.capture(&block))
              ].compact
            )
          end
        end
      end
    end
  end
end
