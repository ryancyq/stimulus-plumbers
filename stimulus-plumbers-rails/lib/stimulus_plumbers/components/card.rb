# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Card < Plumber::Base
      def render(title: nil, **kwargs, &block)
        html_options = merge_html_options(
          { classes: theme.resolve(:card).fetch(:classes, "") },
          kwargs
        )

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
        Card::Section.new(template).render(title: title, **kwargs, &block)
      end
    end
  end
end
