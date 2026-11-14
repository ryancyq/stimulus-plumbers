# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar
      class Turbo
        # Previous/next links, year links at the month level, the grid heading, and the zoom-out link.
        class Header < Plumber::Base
          def render(grid)
            template.content_tag(:div, **merge_html_options(theme.resolve(:calendar_header))) do
              template.safe_join(
                [
                  year_link(grid, -1, "previous", "chevron-double-left"),
                  step_link(grid, -1, "previous", "chevron-left"),
                  heading(grid),
                  zoom_out_link(grid),
                  step_link(grid, 1, "next", "chevron-right"),
                  year_link(grid, 1, "next", "chevron-double-right")
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
            label = I18n.t("stimulus_plumbers.calendar.#{name}_#{grid.level}")
            icon_link(grid, grid.neighbour(direction), grid.level, name, label, icon)
          end

          def year_link(grid, direction, name, icon)
            return unless grid.level == :month

            label = I18n.t("stimulus_plumbers.calendar.#{name}_year")
            icon_link(grid, grid.neighbour_year(direction), :month, "#{name}-year", label, icon)
          end

          def icon_link(grid, date, level, navigation, label, icon)
            period_link(grid, date, level, { aria: { label: label }, data: { navigation: navigation } }) do
              Icon.new(template).render(icon, aria: { hidden: "true" })
            end
          end

          def zoom_out_link(grid)
            return unless grid.zoom_out

            period_link(grid, grid.configuration.displayed, grid.zoom_out, { data: { navigation: "zoom" } }) do
              I18n.t("stimulus_plumbers.calendar.zoom_out.#{grid.zoom_out}")
            end
          end

          # Disabled without a date or a URL.
          def period_link(grid, date, level, attrs, &block)
            url  = grid.url_builder.call(date, level) if date
            data = date ? { date: date.iso8601, level: level } : {}
            html = merge_html_options(theme.resolve(:calendar_navigation), attrs, { data: data })
            return template.link_to(url, **html, &block) if url

            disabled = { role: "link", tabindex: 0, aria: { disabled: "true" } }
            template.content_tag(:a, **merge_html_options(html, disabled), &block)
          end
        end
      end
    end
  end
end
