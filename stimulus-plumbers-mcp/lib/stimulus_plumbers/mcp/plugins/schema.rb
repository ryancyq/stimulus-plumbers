# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    module Plugins
      module Schema
        extend Base

        LOADER_KEY = :schema
        LOADER     = SchemaLoader

        STATIC_RESOURCES = [
          ::MCP::Resource.new(
            uri:         "schema://components",
            name:        "components-index",
            description: "Index of all stimulus-plumbers component theme keys",
            mime_type:   "application/json"
          ),
          ::MCP::Resource.new(
            uri:         "schema://icons",
            name:        "icons",
            description: "All available icon names from the active theme registry",
            mime_type:   "application/json"
          ),
          ::MCP::Resource.new(
            uri:         "schema://stimulus",
            name:        "stimulus-wiring",
            description: "Mapping from Rails component name to the Stimulus controller identifiers it requires",
            mime_type:   "application/json"
          )
        ].freeze

        DYNAMIC_RESOURCE_TEMPLATES = [
          ::MCP::ResourceTemplate.new(
            uri_template: "schema://components/{name}",
            name:         "component-schema",
            description:  "Params, valid values, defaults, and required controllers for a component",
            mime_type:    "application/json"
          )
        ].freeze

        def self.read(uri, store)
          schema = store[:schema]

          case uri
          when "schema://components"
            json_resource(uri, schema[:components].keys)
          when "schema://icons"
            json_resource(uri, schema[:icons])
          when "schema://stimulus"
            json_resource(uri, schema[:stimulus])
          when %r{\Aschema://components/(.+)\z}
            key = Regexp.last_match(1).to_sym
            json_resource(uri, component_data(schema, key) || { error: "unknown component: #{key}" })
          end
        end

        def self.register_tools(server, store)
          schema = store[:schema]
          data_by_component = component_data_map(schema)

          text_tool(server, name: "list_components", description: "Lists all stimulus-plumbers component theme keys") do
            JSON.generate(schema[:components].keys)
          end

          text_tool(
            server,
            name:         "get_component_schema",
            description:  "Returns themed params (e.g. type/variant/size) with valid values, defaults, and " \
                          "required Stimulus controllers. For the full helper surface (icon options, slots) " \
                          "use get_helper_signature",
            input_schema: { properties: { component: { type: "string" } }, required: ["component"] }
          ) do |component:|
            data = data_by_component[component.to_sym]
            data ? JSON.generate(data) : not_found("unknown component: #{component}")
          end

          text_tool(
            server,
            name:         "get_field_as_values",
            description:  "Returns valid as: values for a form builder method",
            input_schema: {
              properties: { builder_method: { type: "string", enum: %w[field collection_field choice] } },
              required:   ["builder_method"]
            }
          ) do |builder_method:|
            values = schema[:field_as][builder_method.to_sym]
            values ? JSON.generate(values) : not_found("unknown builder_method: #{builder_method}")
          end
        end

        # Resolve component_data at module scope; define_tool blocks run in another context.
        def self.component_data_map(schema)
          keys = (schema[:components].keys + schema[:stimulus].keys).uniq
          keys.to_h { |key| [key, component_data(schema, key)] }
        end

        def self.component_data(schema, key)
          params = schema[:components][key]
          wiring = schema[:stimulus]
          return nil unless params || wiring.key?(key)

          (params || {}).merge(controllers: wiring[key] || [])
        end

        private_class_method :component_data_map, :component_data
      end
    end
  end
end
