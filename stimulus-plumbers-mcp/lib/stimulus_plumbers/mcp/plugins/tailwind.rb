# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    module Plugins
      module Tailwind
        extend Base

        LOADER_KEY = :tailwind
        LOADER     = TailwindThemeLoader

        STATIC_RESOURCES = [
          ::MCP::Resource.new(
            uri:         "tailwind://components",
            name:        "tailwind-components-index",
            description: "Index of component keys implemented by the stimulus-plumbers Tailwind theme",
            mime_type:   "application/json"
          )
        ].freeze

        DYNAMIC_RESOURCE_TEMPLATES = [
          ::MCP::ResourceTemplate.new(
            uri_template: "tailwind://components/{name}",
            name:         "tailwind-component-classes",
            description:  "Tailwind CSS utility classes emitted per variant for a component",
            mime_type:    "application/json"
          )
        ].freeze

        def self.read(uri, store)
          tailwind = store[:tailwind]

          case uri
          when "tailwind://components"
            json_resource(uri, tailwind.keys)
          when %r{\Atailwind://components/(.+)\z}
            key = Regexp.last_match(1).to_sym
            json_resource(uri, tailwind[key] || { error: "unknown component: #{key}" })
          end
        end

        def self.register_tools(server, store)
          tailwind = store[:tailwind]

          text_tool(
            server,
            name:         "get_tailwind_classes",
            description:  "Returns Tailwind CSS utility classes emitted per variant for a component",
            input_schema: { properties: { component: { type: "string" } }, required: ["component"] }
          ) do |component:|
            data = tailwind[component.to_sym]
            data ? JSON.generate(data) : not_found("unknown component: #{component}")
          end
        end
      end
    end
  end
end
