# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module DatePicker
      class Navigator < Plumber::Base
        def render(icon_options: nil, **kwargs)
          html_options = merge_html_options(
            { classes: theme.resolve(:calendar_navigation_navigator).fetch(:classes, "") },
            **kwargs
          )

          if icon_options.nil?
            template.content_tag(:button, nil, **html_options)
          else
            template.content_tag(:button, icon(icon_options), **html_options)
          end
        end

        private

        def icon(icon_options)
          Icon::Renderer.new(template).icon(
            classes: theme.resolve(:calendar_navigation_navigator_icon).fetch(:classes, ""),
            **icon_options
          )
        end
      end
    end
  end
end
