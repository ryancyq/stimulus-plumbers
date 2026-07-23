# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Progress
      # Shared stimulus/ARIA wiring for the progress variants (bar, segmented, ring, meter).
      module Shared
        private

        def progress_stimulus_data(value:, min:, max:, variant:, **extra)
          {
            data: {
              controller:               "progress",
              "progress-variant-value": variant,
              "progress-current-value": value,
              "progress-min-value":     min,
              "progress-max-value":     max,
              **extra
            }
          }
        end

        def progress_aria(value:, min:, max:, indeterminate: false)
          aria = { valuemin: min, valuemax: max }
          aria[:valuenow] = value unless indeterminate
          aria
        end
      end
    end
  end
end
