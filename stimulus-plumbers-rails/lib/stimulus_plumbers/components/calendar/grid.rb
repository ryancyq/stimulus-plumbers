# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar
      # One period's grid; subclasses supply rows of dates, the heading, and the step.
      class Grid < Plumber::Base
        attr_reader :configuration

        def initialize(template, configuration)
          super(template)
          @configuration = configuration
        end

        def render
          template.content_tag(:table, **grid_attrs) do
            template.safe_join([render_head, template.content_tag(:tbody) { render_rows }].compact)
          end
        end

        # Selected, then today, then the displayed date, then the first enabled cell.
        def focus_date
          enabled = rows.flatten.select { |date| navigable?(date) && !disabled?(date) }
          candidates.find { |date| enabled.include?(date) } || enabled.first
        end

        def heading_id
          "#{configuration.id}_heading"
        end

        def zoom_out
        end

        # The adjacent period, or nil outside 0001–9999.
        def neighbour(direction)
          date = step(direction)
          date if (1..9999).cover?(date.year)
        end

        private

        def candidates
          [configuration.selected, configuration.today, configuration.displayed].compact.map { |date| unit(date) }
        end

        def grid_attrs
          merge_html_options(
            theme.resolve(:calendar_grid),
            {
              role: "grid",
              aria: { labelledby: heading_id },
              data: {
                "#{STIMULUS_CONTROLLER}-target" => "grid",
                action:                           "keydown->#{STIMULUS_CONTROLLER}#onKeydown",
                displayed:                        configuration.displayed.iso8601,
                view:                             view_name
              }
            }
          )
        end

        def render_head
        end

        def render_rows
          focus = focus_date
          template.safe_join(
            rows.map do |row|
              template.content_tag(:tr) { template.safe_join(row.map { |date| render_cell(date, focus) }) }
            end
          )
        end

        def render_cell(date, focus)
          cell = theme.resolve(:calendar_cell)
          return template.content_tag(:td, nil, **cell) unless navigable?(date)

          template.content_tag(:td, **merge_html_options(cell, cell_attrs(date))) do
            render_control(date, date == focus ? 0 : -1)
          end
        end

        def cell_attrs(_date)
          { role: "gridcell" }
        end

        def control_attrs(date, tabindex)
          merge_html_options(
            theme.resolve(:calendar_date),
            { tabindex: tabindex, aria: state_aria(date), data: control_data(date) }
          )
        end

        def state_aria(date)
          { label: label(date), current: current?(date) ? "date" : nil, disabled: disabled?(date) ? "true" : nil }
            .compact
        end

        def control_data(date)
          { "#{STIMULUS_CONTROLLER}-target" => target, date: date.iso8601, outside: outside?(date) ? "true" : nil }
            .compact
        end

        def current?(date)
          unit(configuration.today) == date
        end

        def navigable?(date)
          (1..9999).cover?(date.year)
        end

        def outside?(_date)
          false
        end

        def unit(date)
          date
        end
      end
    end
  end
end
