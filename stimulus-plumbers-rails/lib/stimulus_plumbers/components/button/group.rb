# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Button
      class Group < Plumber::Base
        def render(...)
          render_group(...)
        end

        private

        def render_group(alignment: :left, direction: :row, **kwargs, &block)
          html_options = merge_html_options(
            theme.resolve(:button_group, alignment: alignment, direction: direction),
            kwargs,
            { role: "group" }
          )
          template.content_tag(:div, template.capture(&block), **html_options)
        end
      end
    end
  end
end
