# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Button
      class Group < Plumber::Base
        def render(...)
          render_group(...)
        end

        def button(content = nil, **kwargs, &block)
          Button.new(template).render(content, **kwargs, &block)
        end

        private

        def render_group(layout: :inline, **kwargs, &block)
          html_options = merge_html_options(
            theme.resolve(:button_group, layout: layout),
            kwargs,
            { role: "group" }
          )
          template.content_tag(:div, template.capture(self, &block), **html_options)
        end
      end
    end
  end
end
