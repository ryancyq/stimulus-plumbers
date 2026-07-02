# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    module Plugins
      module Versions
        extend Base

        LOADER_KEY = :versions
        LOADER     = SourceVersionsLoader

        STATIC_RESOURCES = [
          ::MCP::Resource.new(
            uri:         "versions://sources",
            name:        "source-versions",
            description: "Resolved version (and resolution path, for stimulus) of each gem/package " \
                         "backing this server's data — use to spot version drift between sources",
            mime_type:   "application/json"
          )
        ].freeze

        DYNAMIC_RESOURCE_TEMPLATES = [].freeze

        def self.read(uri, store)
          return unless uri == "versions://sources"

          json_resource(uri, store[:versions])
        end

        def self.register_tools(server, store)
          text_tool(
            server,
            name:        "get_source_versions",
            description: "Returns the resolved version (and resolution path, for stimulus) of each " \
                         "gem/package backing this server's data — use to spot version drift between sources"
          ) do
            JSON.generate(store[:versions])
          end
        end
      end
    end
  end
end
