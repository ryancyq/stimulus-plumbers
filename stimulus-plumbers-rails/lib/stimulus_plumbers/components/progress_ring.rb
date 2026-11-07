# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class ProgressRing < Plumber::Base
      include Progress::Shared

      def render(...)
        render_ring(...)
      end

      private

      def render_ring(value:, max: 100, min: 0, indeterminate: false, size: nil, **kwargs)
        current = clamp(value, min, max)
        icon_attrs = merge_html_options(
          theme.resolve(:progress_ring, size: size),
          kwargs,
          progress_stimulus_attrs(
            value: current, min: min, max: max, variant: "ring", "progress-indeterminate-value": indeterminate
          ),
          {
            role:  "progressbar",
            aria:  progress_aria(value: current, min: min, max: max, indeterminate: indeterminate),
            style: progress_style(current, min, max, kwargs[:style])
          }
        )
        Components::Icon.new(template).render("progress-ring", **icon_attrs)
      end
    end
  end
end
