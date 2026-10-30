# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar
      class MonthsOfYear < Grid
        COLUMNS = 4

        def rows
          @rows ||= (1..12).map { |month| Date.new(configuration.displayed.year, month, 1) }.each_slice(COLUMNS).to_a
        end

        def heading
          configuration.displayed.year.to_s
        end

        def view_name
          :year
        end

        def step(direction)
          configuration.displayed.beginning_of_year >> (12 * direction)
        end

        def zoom_out
          :decade
        end

        private

        def target
          "period"
        end

        def control_view
          :month
        end

        # Links to the month; an unavailable month or one without a URL has no href.
        def render_control(date, tabindex)
          text = I18n.l(date, format: "%B")
          return template.content_tag(:a, text, role: "link", **control_attrs(date, tabindex)) if disabled?(date)

          template.link_to(text, period_url(date), **control_attrs(date, tabindex))
        end

        def label(date)
          I18n.l(date, format: "%B %Y")
        end

        def disabled?(date)
          configuration.availability.month_disabled?(date.year, date.month) || period_url(date).nil?
        end

        def unit(date)
          date.beginning_of_month
        end
      end
    end
  end
end
