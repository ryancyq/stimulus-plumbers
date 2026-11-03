# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar
      class Turbo
        # Previous/next links, the grid heading, and the zoom-out link.
        class Header < Plumber::Base
          def render(grid)
            template.content_tag(:div, **merge_html_options(theme.resolve(:calendar_header))) do
              template.safe_join(
                [
                  step_link(grid, -1, "previous", "chevron-left"),
                  heading(grid),
                  zoom_out_link(grid),
                  step_link(grid, 1, "next", "chevron-right")
                ].compact
              )
            end
          end

          private

          def heading(grid)
            template.content_tag(
              :h2, grid.heading, **merge_html_options(theme.resolve(:calendar_heading), { id: grid.heading_id })
            )
          end

          def step_link(grid, direction, name, icon)
            target = grid.neighbour(direction)
            return unless target

            label = I18n.t("stimulus_plumbers.calendar.#{name}_#{grid.view_name}")
            template.link_to(
              grid.link.call(target, grid.view_name),
              **merge_html_options(theme.resolve(:calendar_navigation), { aria: { label: label }, data: { navigation: name } })
            ) { Icon.new(template).render(icon, aria: { hidden: "true" }) }
          end

          def zoom_out_link(grid)
            return unless grid.zoom_out

            template.link_to(
              I18n.t("stimulus_plumbers.calendar.zoom_out.#{grid.zoom_out}"),
              grid.link.call(grid.configuration.displayed, grid.zoom_out),
              **merge_html_options(theme.resolve(:calendar_navigation), { data: { navigation: "zoom" } })
            )
          end
        end
      end
    end
  end
end
