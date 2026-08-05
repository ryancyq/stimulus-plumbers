# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module ProgressHelper
      def sp_progress_bar(value:, min: 0, max: 100, indeterminate: false, format: nil, **kwargs)
        Components::ProgressBar.new(self).render(
          value: value, min: min, max: max, indeterminate: indeterminate, format: format, **kwargs
        )
      end

      def sp_progress_segmented(value:, segments:, min: 0, max: 100, mode: :discrete, indeterminate: false, ramp: nil, **kwargs)
        Components::ProgressBar.new(self).render_segmented(
          value: value, segments: segments, min: min, max: max, mode: mode, indeterminate: indeterminate, ramp: ramp, **kwargs
        )
      end

      def sp_progress_ring(value:, min: 0, max: 100, indeterminate: false, size: nil, **kwargs)
        Components::ProgressRing.new(self).render(
          value: value, min: min, max: max, indeterminate: indeterminate, size: size, **kwargs
        )
      end

      def sp_progress_meter(value:, min: 0, max: 100, low: nil, high: nil, optimum: nil, **kwargs)
        Components::ProgressMeter.new(self).render(
          value: value, min: min, max: max, low: low, high: high, optimum: optimum, **kwargs
        )
      end
    end
  end
end
