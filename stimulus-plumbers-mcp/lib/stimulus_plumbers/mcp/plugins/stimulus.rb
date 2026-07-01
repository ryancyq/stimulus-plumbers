# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    module Plugins
      module Stimulus
        extend Base

        LOADER_KEY = :stimulus
        LOADER     = StimulusManifestLoader

        STATIC_RESOURCES = [
          ::MCP::Resource.new(
            uri:         "stimulus://controllers",
            name:        "stimulus-controllers-index",
            description: "Index of all Stimulus controller identifiers in @stimulus-plumbers/controllers",
            mime_type:   "application/json"
          )
        ].freeze

        DYNAMIC_RESOURCE_TEMPLATES = [
          ::MCP::ResourceTemplate.new(
            uri_template: "stimulus://controllers/{identifier}",
            name:         "stimulus-controller-schema",
            description:  "Targets, values, outlets, and classes for a Stimulus controller",
            mime_type:    "application/json"
          )
        ].freeze

        def self.read(uri, store)
          controllers = store[:stimulus]

          case uri
          when "stimulus://controllers"
            json_resource(uri, controllers.keys)
          when %r{\Astimulus://controllers/(.+)\z}
            identifier = Regexp.last_match(1)
            json_resource(uri, controllers[identifier] || { error: "unknown controller: #{identifier}" })
          end
        end

        def self.register_tools(server, store)
          controllers = store[:stimulus]

          text_tool(
            server,
            name:        "list_controllers",
            description: "Lists all Stimulus controller identifiers provided by @stimulus-plumbers/controllers"
          ) do
            JSON.generate(controllers.keys)
          end

          text_tool(
            server,
            name:         "get_controller_schema",
            description:  "Returns targets, values (with types and defaults), outlets, and classes for a Stimulus controller",
            input_schema: { properties: { controller: { type: "string" } }, required: ["controller"] }
          ) do |controller:|
            data = controllers[controller]
            data ? JSON.generate(data) : not_found("unknown controller: #{controller}")
          end
        end
      end
    end
  end
end
