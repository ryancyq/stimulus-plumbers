# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class ProgressBar < Plumber::Base
      def render(...) = render_bar(...)

      private

      def render_bar(value:, min: 0, max: 100, indeterminate: false, **kwargs)
        html_options = merge_html_options(
          theme.resolve(:progress_bar),
          kwargs,
          stimulus_data(value: value, min: min, max: max, indeterminate: indeterminate),
          { role: "progressbar", aria: progress_aria(value: value, min: min, max: max, indeterminate: indeterminate) }
        )
        template.content_tag(:div, render_fill, **html_options)
      end

      def render_fill
        template.content_tag(
          :div,
          nil,
          **merge_html_options(theme.resolve(:progress_bar_fill), { data: { "progress-target": "fill" } })
        )
      end

      def progress_aria(value:, min:, max:, indeterminate:)
        aria = { valuemin: min, valuemax: max }
        aria[:valuenow] = value unless indeterminate
        aria
      end

      def stimulus_data(value:, min:, max:, indeterminate:)
        {
          data: {
            controller:                     "progress",
            "progress-variant-value":       "bar",
            "progress-current-value":       value,
            "progress-min-value":           min,
            "progress-max-value":           max,
            "progress-indeterminate-value": indeterminate
          }
        }
      end
    end
  end
end
