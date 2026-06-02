# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Card
      class Section < Plumber::Base
        def render(...)
          render_section(...)
        end

        private

        def render_section(title: nil, title_tag: :h3, **kwargs, &block)
          html_options = merge_html_options(
            theme.resolve(:card_section),
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
end
