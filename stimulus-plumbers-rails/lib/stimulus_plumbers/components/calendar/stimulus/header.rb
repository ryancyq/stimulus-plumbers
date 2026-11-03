# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar
      class Stimulus
        # Previous/next and year buttons, the grid heading, and the zoom button; label-free until the controller draws them.
        class Header < Plumber::Base
          def render(configuration)
            template.content_tag(:div, **merge_html_options(theme.resolve(:calendar_header))) do
              template.safe_join(
                [
                  step_button("previous-year", "chevron-double-left"),
                  step_button("previous", "chevron-left"),
                  heading(configuration),
                  navigation_button("zoom"),
                  step_button("next", "chevron-right"),
                  step_button("next-year", "chevron-double-right")
                ]
              )
            end
          end

          private

          def heading(configuration)
            template.content_tag(
              :h2, nil, **merge_html_options(theme.resolve(:calendar_heading), { id: configuration.heading_id })
            )
          end

          def step_button(name, icon)
            navigation_button(name) { Icon.new(template).render(icon, aria: { hidden: "true" }) }
          end

          def navigation_button(name, &block)
            template.content_tag(
              :button,
              block ? template.capture(&block) : nil,
              type: "button",
              **merge_html_options(theme.resolve(:calendar_navigation), { data: { navigation: name } })
            )
          end
        end
      end
    end
  end
end
