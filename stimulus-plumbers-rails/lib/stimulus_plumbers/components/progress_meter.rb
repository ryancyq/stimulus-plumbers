# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class ProgressMeter < Plumber::Base
      include Progress::Shared

      def render(...)
        render_meter(...)
      end

      private

      def render_meter(value:, min: 0, max: 100, low: nil, high: nil, optimum: nil, **kwargs)
        attrs = { value: value, min: min, max: max, low: low, high: high, optimum: optimum }.compact
        html_options = merge_html_options(
          theme.resolve(:progress_meter),
          kwargs,
          progress_stimulus_data(
            value:             value,
            min:               min,
            max:               max,
            variant:           "meter",
            "progress-target": "meter",
            **threshold_data(low: low, high: high, optimum: optimum)
          ),
          attrs
        )
        template.content_tag(:meter, nil, **html_options)
      end

      def threshold_data(low:, high:, optimum:)
        data = {}
        data[:"progress-low-value"]     = low if low
        data[:"progress-high-value"]    = high if high
        data[:"progress-optimum-value"] = optimum if optimum
        data
      end
    end
  end
end
