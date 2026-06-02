# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Card < Plumber::Base
      def render(...)
        render_card(...)
      end

      def section(...)
        Card::Section.new(template).render(...)
      end

      private

      def render_card(title: nil, title_tag: :h2, **kwargs, &block)
        html_options = merge_html_options(
          theme.resolve(:card),
          kwargs
        )

        template.content_tag(:div, **html_options) do
          template.safe_join(
            [
              (template.content_tag(title_tag, title) if title.present?),
              template.capture(&block)
            ]
          )
        end
      end
    end
  end
end
