# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class ProgressRing < Plumber::Base
      def render(...) = render_ring(...)

      private

      def render_ring(value:, max: 100, min: 0, indeterminate: false, **kwargs)
        icon_options = merge_html_options(
          theme.resolve(:progress_ring),
          kwargs,
          stimulus_data(value: value, min: min, max: max, indeterminate: indeterminate),
          { role: "progressbar", aria: progress_aria(value: value, min: min, max: max, indeterminate: indeterminate) }
        )
        Components::Icon.new(template).render(name: "progress-ring", **icon_options)
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
            "progress-variant-value":       "ring",
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
