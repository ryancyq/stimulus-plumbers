# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Schema
      module Icon
        DEFAULTS = {
          fill:            "none",
          view_box:        "0 0 24 24",
          width:           "24",
          height:          "24",
          stroke:          "currentColor",
          stroke_width:    1.5,
          stroke_linecap:  :round,
          stroke_linejoin: :round
        }.freeze

        ATTRS = ([:d] + DEFAULTS.keys).freeze

        def self.resolve(icon_data)
          return unless icon_data.is_a?(Hash)

          merged = DEFAULTS.merge(icon_data.slice(*ATTRS)).transform_values(&:to_s)
          return merged if merged[:d].present?

          StimulusPlumbers::Logger.warn("Icon missing required :d attribute")
          nil
        end
      end
    end
  end
end
