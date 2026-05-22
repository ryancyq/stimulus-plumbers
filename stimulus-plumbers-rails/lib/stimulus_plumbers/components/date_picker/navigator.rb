# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module DatePicker
      class Navigator < Plumber::Base
        def render(...)
          render_navigator(...)
        end

        private

        def render_navigator(icon: nil, **kwargs)
          html_options = merge_html_options(
            { classes: theme.resolve(:calendar_navigation_navigator).fetch(:classes, "") },
            kwargs
          )
          Components::Button.new(template).render(variant: :ghost, size: nil, icon_leading: icon, **html_options)
        end
      end
    end
  end
end
