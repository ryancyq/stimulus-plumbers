# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class ProgressMeter < Plumber::Base
      def render(...)
        render_meter(...)
      end

      private

      def render_meter(value:, min: 0, max: 100, low: nil, high: nil, optimum: nil, **kwargs)
        attrs = { value: value, min: min, max: max, low: low, high: high, optimum: optimum }.compact
        html_options = merge_html_options(
          theme.resolve(:progress_meter),
          kwargs,
          stimulus_data(value: value, min: min, max: max, low: low, high: high, optimum: optimum),
          attrs
        )
        template.content_tag(:meter, nil, **html_options)
      end

      def stimulus_data(value:, min:, max:, low:, high:, optimum:)
        data = {
          controller:               "progress",
          "progress-target":        "meter",
          "progress-variant-value": "meter",
          "progress-current-value": value,
          "progress-min-value":     min,
          "progress-max-value":     max
        }
        data["progress-low-value"]     = low if low
        data["progress-high-value"]    = high if high
        data["progress-optimum-value"] = optimum if optimum
        { data: data }
      end
    end
  end
end
