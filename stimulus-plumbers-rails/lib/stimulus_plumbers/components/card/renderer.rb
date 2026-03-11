# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Card
      class Renderer < Plumber::Base
        def card(title: nil, **kwargs, &block)
          self.html_options = {
            classes: theme.resolve(:card).fetch(:classes, ""),
            **kwargs
          }

          template.content_tag(:div, **html_options) do
            template.safe_join(
              [
                (template.content_tag(:h2, title) if title.present?),
                template.capture(&block)
              ].compact
            )
          end
        end

        def section(title: nil, **kwargs, &block)
          self.html_options = {
            classes: theme.resolve(:card_section).fetch(:classes, ""),
            **kwargs
          }

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
