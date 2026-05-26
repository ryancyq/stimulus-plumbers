# frozen_string_literal: true

require "rexml/document"
require "stimulus_plumbers/themes/schema/icon"

module StimulusPlumbers
  module Themes
    module Icons
      module External
        SVG_RENAME     = Schema::Icon::SVG_ATTR_NAMES.invert.freeze
        ELEMENT_RENAME = Schema::Icon::ELEMENT_ATTR_NAMES.invert.freeze

        def include?(key)
          File.exist?(svg_path(key))
        end

        def fetch(key)
          file = svg_path(key)
          parse_svg(key, File.read(file)) if File.exist?(file)
        end

        private

        def svg_defaults(_key)
          {}
        end

        def parse_svg(key, content)
          doc  = REXML::Document.new(content)
          root = doc.root

          result = svg_defaults(key)
          root.attributes.each_attribute do |attr|
            result[SVG_RENAME.fetch(attr.name, attr.name.to_sym)] = attr.value
          end

          elements = parse_elements(root)
          return if elements.empty?

          result[:elements] = elements
          result
        end

        def parse_elements(node)
          node.elements.flat_map do |el|
            el.name == "g" ? parse_elements(el) : [parse_element(el)].compact
          end
        end

        def parse_element(node)
          attrs = { tag: node.name.to_sym }
          node.attributes.each_attribute do |attr|
            attrs[ELEMENT_RENAME.fetch(attr.name, attr.name.tr("-", "_").to_sym)] = attr.value
          end
          attrs if attrs.size > 1
        end
      end
    end
  end
end
