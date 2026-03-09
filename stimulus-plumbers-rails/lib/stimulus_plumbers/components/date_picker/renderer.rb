# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module DatePicker
      class Renderer
        STIMULUS_CONTROLLER = "calendar-month"

        attr_reader :template, :theme

        def initialize(template, theme)
          @template = template
          @theme    = theme
        end

        def month(**html_options)
          data = { controller: STIMULUS_CONTROLLER }.merge(html_options.delete(:data) || {})

          template.content_tag(:div, data: data, **html_options) do
            template.safe_join(
              [
                header,
                days_of_week_grid,
                days_of_month_grid
              ]
            )
          end
        end

        private

        def target(name)
          { "#{STIMULUS_CONTROLLER}-target": name }
        end

        def header
          template.content_tag(:div, class: "flex justify-between") do
            template.safe_join(
              [
                template.content_tag(:button, left_arrow_svg, data: target("previous"), "aria-label": "Previous month"),
                template.content_tag(:div) do
                  template.safe_join(
                    [
                      template.content_tag(:span, nil, data: target("month")),
                      template.content_tag(:span, nil, data: target("year"))
                    ]
                  )
                end,
                template.content_tag(:button, right_arrow_svg, data: target("next"), "aria-label": "Next month")
              ]
            )
          end
        end

        def days_of_week_grid
          template.content_tag(
            :div,
            nil,
            class: "grid grid-cols-7 place-items-center",
            data:  target("daysOfWeek")
          )
        end

        def days_of_month_grid
          template.content_tag(
            :div,
            nil,
            class: "grid grid-cols-7 place-items-center",
            role:  "grid",
            data:  target("daysOfMonth")
          )
        end

        def left_arrow_svg
          template.content_tag(
            :svg,
            xmlns:          "http://www.w3.org/2000/svg",
            fill:           "none",
            viewBox:        "0 0 24 24",
            "stroke-width": "1.5",
            stroke:         "currentColor",
            class:          "size-6"
          ) do
            template.tag.path(
              "stroke-linecap":  "round",
              "stroke-linejoin": "round",
              d:                 "M10.5 19.5 3 12m0 0 7.5-7.5M3 12h18"
            )
          end
        end

        def right_arrow_svg
          template.content_tag(
            :svg,
            xmlns:          "http://www.w3.org/2000/svg",
            fill:           "none",
            viewBox:        "0 0 24 24",
            "stroke-width": "1.5",
            stroke:         "currentColor",
            class:          "size-6"
          ) do
            template.tag.path(
              "stroke-linecap":  "round",
              "stroke-linejoin": "round",
              d:                 "M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3"
            )
          end
        end
      end
    end
  end
end
