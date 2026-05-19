# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class ActionList
      class Section < Plumber::Base
        def render(title: nil, **kwargs, &block)
          template.content_tag(:li, **kwargs) do
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
