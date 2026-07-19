# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    module Plugins
      class Tailwind < Base
        class << self
          def loader_key
            :tailwind
          end

          def loader
            TailwindLoader
          end

          def static_resources
            [
              ::MCP::Resource.new(
                uri:         "component://tailwind",
                name:        "component-tailwind-index",
                description: "Index of component keys implemented by the stimulus-plumbers Tailwind theme",
                mime_type:   "application/json"
              )
            ].freeze
          end

          def dynamic_resource_templates
            [
              ::MCP::ResourceTemplate.new(
                uri_template: "component://{name}/tailwind",
                name:         "component-tailwind-classes",
                description:  "Tailwind CSS utility classes emitted per variant for a component",
                mime_type:    "application/json"
              )
            ].freeze
          end

          def read(uri, store)
            tailwind = store[:tailwind]

            case uri
            when "component://tailwind"
              json_resource(uri, tailwind.keys)
            when %r{\Acomponent://([^/]+)/tailwind\z}
              key = Regexp.last_match(1).to_sym
              json_resource(uri, tailwind[key] || { error: "unknown component: #{key}" })
            end
          end

          def register_tools(server, store)
            tailwind = store[:tailwind]

            register_list_component_tailwind(server, tailwind)
            register_get_component_tailwind(server, tailwind)
          end

          private

          def register_list_component_tailwind(server, tailwind)
            text_tool(
              server,
              name:        "list_component_tailwind",
              description: "Lists component keys implemented by the stimulus-plumbers Tailwind theme"
            ) do
              JSON.generate(tailwind.keys)
            end
          end

          def register_get_component_tailwind(server, tailwind)
            text_tool(
              server,
              name:         "get_component_tailwind",
              description:  "Returns Tailwind CSS utility classes emitted per variant for a component. " \
                            "For themed params/controllers use get_component_schema; for the Rails helper " \
                            "surface use get_component_helper",
              input_schema: { properties: { name: { type: "string" } }, required: ["name"] }
            ) do |name:|
              data = tailwind[name.to_sym]
              data ? JSON.generate(data) : not_found("unknown component: #{name}")
            end
          end
        end
      end
    end
  end
end
