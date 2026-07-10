# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module ProgressHelper
      def sp_progress_bar(value:, min: 0, max: 100, indeterminate: false, **kwargs)
        Components::ProgressBar.new(self).render(value: value, min: min, max: max, indeterminate: indeterminate, **kwargs)
      end

      def sp_progress_ring(value:, min: 0, max: 100, indeterminate: false, **kwargs)
        Components::ProgressRing.new(self).render(value: value, min: min, max: max, indeterminate: indeterminate, **kwargs)
      end

      def sp_progress_meter(value:, min: 0, max: 100, low: nil, high: nil, optimum: nil, **kwargs)
        Components::ProgressMeter.new(self).render(
          value: value, min: min, max: max, low: low, high: high, optimum: optimum, **kwargs
        )
      end
    end
  end
end
