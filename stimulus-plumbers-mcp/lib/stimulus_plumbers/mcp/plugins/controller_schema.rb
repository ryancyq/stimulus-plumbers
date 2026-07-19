# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    module Plugins
      class ControllerSchema < Base
        class << self
          def loader_key
            :controller_schema
          end

          def loader
            ControllerSchemaLoader
          end

          def static_resources
            [
              ::MCP::Resource.new(
                uri:         "controller://index",
                name:        "controllers-index",
                description: "Index of all Stimulus controller identifiers in @stimulus-plumbers/controllers",
                mime_type:   "application/json"
              )
            ].freeze
          end

          def dynamic_resource_templates
            [
              ::MCP::ResourceTemplate.new(
                uri_template: "controller://{name}/schema",
                name:         "controller-schema",
                description:  "Targets, values, outlets, and classes for a Stimulus controller",
                mime_type:    "application/json"
              )
            ].freeze
          end

          def read(uri, store)
            controllers = store[:controller_schema]

            case uri
            when "controller://index"
              json_resource(uri, controllers.keys)
            when %r{\Acontroller://([^/]+)/schema\z}
              identifier = Regexp.last_match(1)
              json_resource(uri, controllers[identifier] || { error: "unknown controller: #{identifier}" })
            end
          end

          def register_tools(server, store)
            controllers = store[:controller_schema]

            register_list_controllers(server, controllers)
            register_get_controller_schema(server, controllers)
          end

          private

          def register_list_controllers(server, controllers)
            text_tool(
              server,
              name:        "list_controllers",
              description: "Lists all Stimulus controller identifiers provided by @stimulus-plumbers/controllers"
            ) do
              JSON.generate(controllers.keys)
            end
          end

          def register_get_controller_schema(server, controllers)
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
end
