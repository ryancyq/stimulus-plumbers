# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Date
        class Navigator < Plumber::Base
          def render(...)
            render_navigator(...)
          end

          private

          def render_navigator(icon: nil, **kwargs, &block)
            html_options = merge_html_options(
              theme.resolve(:combobox_date_navigation_navigator),
              kwargs
            )
            Components::Button.new(template).render(variant: :ghost, size: nil, icon_leading: icon, **html_options, &block)
          end
        end
      end
    end
  end
end
