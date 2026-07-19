# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    module Plugins
      class ComponentSchema < Base
        class << self
          def loader_key
            :component_schema
          end

          def loader
            ComponentSchemaLoader
          end

          def static_resources
            [
              ::MCP::Resource.new(
                uri:         "component://index",
                name:        "components-index",
                description: "Index of all stimulus-plumbers component theme keys",
                mime_type:   "application/json"
              ),
              ::MCP::Resource.new(
                uri:         "component://integration",
                name:        "component-integration",
                description: "Mapping from Rails component name to the Stimulus controller identifiers it requires",
                mime_type:   "application/json"
              )
            ].freeze
          end

          def dynamic_resource_templates
            [
              ::MCP::ResourceTemplate.new(
                uri_template: "component://{name}/schema",
                name:         "component-schema",
                description:  "Params, valid values, defaults, and required controllers for a component",
                mime_type:    "application/json"
              )
            ].freeze
          end

          def read(uri, store)
            schema = store[:component_schema]

            case uri
            when "component://index"
              json_resource(uri, schema[:components].keys)
            when "component://integration"
              json_resource(uri, schema[:controllers])
            when %r{\Acomponent://([^/]+)/schema\z}
              key = Regexp.last_match(1).to_sym
              json_resource(uri, component_data(schema, key) || { error: "unknown component: #{key}" })
            end
          end

          def register_tools(server, store)
            schema = store[:component_schema]
            data_by_component = component_data_map(schema)

            register_list_components(server, schema)
            register_get_component_schema(server, data_by_component)
            register_get_field_as_values(server, schema)
            register_get_field_as_controller(server, schema)
          end

          private

          def register_list_components(server, schema)
            text_tool(server, name: "list_components", description: "Lists all stimulus-plumbers component theme keys") do
              JSON.generate(schema[:components].keys)
            end
          end

          def register_get_component_schema(server, data_by_component)
            text_tool(
              server,
              name:         "get_component_schema",
              description:  "Returns themed params (e.g. type/variant/size) with valid values, defaults, and " \
                            "required Stimulus controllers. For the full helper surface (icon options, slots) " \
                            "use get_component_helper. Keys are renderer-level (e.g. combobox_listbox), not " \
                            "f.field(as:) values — for the as: value's backing controller use get_field_as_controller",
              input_schema: { properties: { name: { type: "string" } }, required: ["name"] }
            ) do |name:|
              data = data_by_component[name.to_sym]
              data ? JSON.generate(data) : not_found("unknown component: #{name}")
            end
          end

          def register_get_field_as_values(server, schema)
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

          def register_get_field_as_controller(server, schema)
            text_tool(
              server,
              name:         "get_field_as_controller",
              description:  "Returns the Stimulus controller identifier backing an f.field/f.collection_field " \
                            "as: value (e.g. \"select\" -> \"combobox-dropdown\"), for as: values whose picker " \
                            "is controller-backed. Plain input as: values (text, email, file, ...) return not-found",
              input_schema: { properties: { as: { type: "string" } }, required: ["as"] }
            ) do |as:|
              controller = schema[:field_as_controllers][as.to_sym]
              controller ? JSON.generate(controller: controller) : not_found("no dedicated controller for as: #{as}")
            end
          end

          # Resolve component_data at module scope; define_tool blocks run in another context.
          def component_data_map(schema)
            keys = (schema[:components].keys + schema[:controllers].keys).uniq
            keys.to_h { |key| [key, component_data(schema, key)] }
          end

          def component_data(schema, key)
            params = schema[:components][key]
            required = schema[:controllers]
            return nil unless params || required.key?(key)

            (params || {}).merge(controllers: required[key] || [])
          end
        end
      end
    end
  end
end
