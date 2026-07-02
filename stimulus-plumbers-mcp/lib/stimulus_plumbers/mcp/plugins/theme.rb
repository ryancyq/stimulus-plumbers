# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    module Plugins
      module Theme
        extend Base

        LOADER_KEY = :theme
        LOADER     = ThemeLoader

        STATIC_RESOURCES = [
          ::MCP::Resource.new(
            uri:         "theme://base",
            name:        "theme-base",
            description: "Guide for implementing a custom stimulus-plumbers theme: method convention, return format",
            mime_type:   "text/markdown"
          ),
          ::MCP::Resource.new(
            uri:         "theme://components",
            name:        "theme-components-index",
            description: "Index of all component keys that can be implemented in a custom theme",
            mime_type:   "application/json"
          )
        ].freeze

        DYNAMIC_RESOURCE_TEMPLATES = [
          ::MCP::ResourceTemplate.new(
            uri_template: "theme://components/{name}",
            name:         "theme-component-interface",
            description:  "Method name, param signature, and return contract for implementing a component in a custom theme",
            mime_type:    "application/json"
          )
        ].freeze

        def self.read(uri, store)
          theme = store[:theme]

          case uri
          when "theme://base"
            text_resource(uri, "text/markdown", theme[:base_doc])
          when "theme://components"
            json_resource(uri, theme[:components].keys)
          when %r{\Atheme://components/(.+)\z}
            key = Regexp.last_match(1).to_sym
            json_resource(uri, theme[:components][key] || { error: "unknown component: #{key}" })
          end
        end

        def self.register_tools(server, store)
          theme = store[:theme]

          text_tool(
            server,
            name:         "get_theme_interface",
            description:  "Returns the method name, param signature, and return contract for implementing " \
                          "a component in a custom theme. For the built-in Tailwind theme's output use " \
                          "get_tailwind_classes; for themed params use get_component_schema",
            input_schema: { properties: { component: { type: "string" } }, required: ["component"] }
          ) do |component:|
            data = theme[:components][component.to_sym]
            data ? JSON.generate(data) : not_found("unknown component: #{component}")
          end
        end
      end
    end
  end
end
