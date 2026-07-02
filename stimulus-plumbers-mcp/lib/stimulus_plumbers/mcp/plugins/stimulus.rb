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
            uri:         "controller://index",
            name:        "controllers-index",
            description: "Index of all Stimulus controller identifiers in @stimulus-plumbers/controllers",
            mime_type:   "application/json"
          )
        ].freeze

        DYNAMIC_RESOURCE_TEMPLATES = [
          ::MCP::ResourceTemplate.new(
            uri_template: "controller://{name}/schema",
            name:         "controller-schema",
            description:  "Targets, values, outlets, and classes for a Stimulus controller",
            mime_type:    "application/json"
          )
        ].freeze

        def self.read(uri, store)
          controllers = store[:stimulus]

          case uri
          when "controller://index"
            json_resource(uri, controllers.keys)
          when %r{\Acontroller://([^/]+)/schema\z}
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
            description:  "Returns targets, values (with types and defaults), outlets, and classes for a " \
                          "Stimulus controller. For narrative usage docs use get_controller_docs",
            input_schema: { properties: { name: { type: "string" } }, required: ["name"] }
          ) do |name:|
            data = controllers[name]
            data ? JSON.generate(data) : not_found("unknown controller: #{name}")
          end
        end
      end
    end
  end
end
