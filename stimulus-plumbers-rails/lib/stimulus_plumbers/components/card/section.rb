# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Card
      class Section < Plumber::Base
        def render(title: nil, **kwargs, &block)
          html_options = merge_html_options(
            { classes: theme.resolve(:card_section).fetch(:classes, "") },
            kwargs
          )

          template.content_tag(:div, **html_options) do
            template.safe_join(
              [
                (template.content_tag(:h3, title) if title.present?),
                template.capture(&block)
              ].compact
            )
          end
        end
      end
    end
  end
end
