# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Schema
      module Icon
        extend self

        SVG_ATTR_DEFAULTS = {
          xmlns:        "http://www.w3.org/2000/svg",
          fill:         "none",
          view_box:     "0 0 24 24",
          width:        "24",
          height:       "24",
          stroke:       "currentColor",
          stroke_width: 1.5
        }.freeze

        SVG_ATTR_NAMES = {
          view_box:     "viewBox",
          stroke_width: "stroke-width"
        }.freeze

        ELEMENT_ATTRS = {
          path:     %i[d fill fill_rule clip_rule stroke_linecap stroke_linejoin opacity].freeze,
          circle:   %i[cx cy r].freeze,
          ellipse:  %i[cx cy rx ry].freeze,
          rect:     %i[x y width height rx ry].freeze,
          line:     %i[x1 y1 x2 y2].freeze,
          polyline: %i[points].freeze,
          polygon:  %i[points].freeze
        }.freeze

        ELEMENT_ATTR_NAMES = {
          fill_rule:       "fill-rule",
          clip_rule:       "clip-rule",
          stroke_width:    "stroke-width",
          stroke_linecap:  "stroke-linecap",
          stroke_linejoin: "stroke-linejoin"
        }.freeze

        def resolve(icon_data)
          return unless icon_data.is_a?(Hash)

          elements = Array(icon_data[:elements]).filter_map do |element|
            next unless element.is_a?(Hash) && ELEMENT_ATTRS.key?(element[:tag])

            { tag: element[:tag] }.merge(resolve_element_attrs(element))
          end
          return if elements.empty?

          resolve_svg_attrs(icon_data).tap do |attrs|
            attrs[:elements] = elements
          end
        end

        private

        def resolve_svg_attrs(svg_data)
          SVG_ATTR_DEFAULTS
            .merge(svg_data.slice(*SVG_ATTR_DEFAULTS.keys))
            .transform_keys { |key| SVG_ATTR_NAMES.fetch(key, key.to_s) }
            .transform_values(&:to_s)
        end

        def resolve_element_attrs(element_data)
          element_data.slice(*ELEMENT_ATTRS[element_data[:tag]])
                      .transform_keys { |key| ELEMENT_ATTR_NAMES.fetch(key, key.to_s) }
                      .transform_values(&:to_s)
        end
      end
    end
  end
end
