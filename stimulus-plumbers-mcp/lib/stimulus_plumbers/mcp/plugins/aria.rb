# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    module Plugins
      module Aria
        extend Base

        LOADER_KEY = :aria
        LOADER     = AriaLoader

        STATIC_RESOURCES = [
          ::MCP::Resource.new(
            uri:         "aria://reference",
            name:        "aria-reference",
            description: "WCAG 2.1 AA criteria, JS keyboard navigation patterns, and per-component ARIA " \
                         "patterns for this library. For generic ARIA role/WCAG technique reference not " \
                         "specific to this library, use the MDN MCP server (https://developer.mozilla.org/en-US/mcp)",
            mime_type:   "text/markdown"
          )
        ].freeze

        DYNAMIC_RESOURCE_TEMPLATES = [].freeze

        def self.read(uri, store)
          return unless uri == "aria://reference"

          text_resource(uri, "text/markdown", store[:aria])
        end
      end
    end
  end
end
