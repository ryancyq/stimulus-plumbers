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
          circle:   %i[cx cy r class stroke stroke_width stroke_linecap].freeze,
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
          SVG_ATTR_DEFAULTS.merge(svg_data).filter_map do |key, value|
            next unless svg_attr_allowed?(key)

            [svg_attr_name(key), value.to_s]
          end.to_h
        end

        def svg_attr_allowed?(key)
          SVG_ATTR_DEFAULTS.key?(key) || data_or_aria_attr?(key)
        end

        def svg_attr_name(key)
          return key.to_s.tr("_", "-") if data_or_aria_attr?(key)

          SVG_ATTR_NAMES.fetch(key, key.to_s)
        end

        def resolve_element_attrs(element_data)
          element_data.filter_map do |key, value|
            next if key == :tag
            next unless element_attr_allowed?(element_data[:tag], key)

            [element_attr_name(key), value.to_s]
          end.to_h
        end

        def element_attr_allowed?(tag, key)
          ELEMENT_ATTRS.fetch(tag, []).include?(key) || data_or_aria_attr?(key)
        end

        def element_attr_name(key)
          return key.to_s.tr("_", "-") if data_or_aria_attr?(key)

          ELEMENT_ATTR_NAMES.fetch(key, key.to_s)
        end

        def data_or_aria_attr?(key)
          key.to_s.start_with?("data_", "aria_")
        end
      end
    end
  end
end
