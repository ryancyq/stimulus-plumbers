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
            uri:         "component://theme",
            name:        "component-theme-index",
            description: "Index of all component keys that can be implemented in a custom theme",
            mime_type:   "application/json"
          )
        ].freeze

        DYNAMIC_RESOURCE_TEMPLATES = [
          ::MCP::ResourceTemplate.new(
            uri_template: "component://{name}/theme",
            name:         "component-theme-interface",
            description:  "Method name, param signature, and return contract for implementing a component in a custom theme",
            mime_type:    "application/json"
          )
        ].freeze

        def self.read(uri, store)
          theme = store[:theme]

          case uri
          when "theme://base"
            text_resource(uri, "text/markdown", theme[:base_doc])
          when "component://theme"
            json_resource(uri, theme[:components].keys)
          when %r{\Acomponent://([^/]+)/theme\z}
            key = Regexp.last_match(1).to_sym
            json_resource(uri, theme[:components][key] || { error: "unknown component: #{key}" })
          end
        end

        def self.register_tools(server, store)
          theme = store[:theme]

          text_tool(
            server,
            name:         "get_component_theme",
            description:  "Returns the method name, param signature, and return contract for implementing " \
                          "a component in a custom theme. For the built-in Tailwind theme's output use " \
                          "get_component_tailwind; for themed params use get_component_schema",
            input_schema: { properties: { name: { type: "string" } }, required: ["name"] }
          ) do |name:|
            data = theme[:components][name.to_sym]
            data ? JSON.generate(data) : not_found("unknown component: #{name}")
          end
        end
      end
    end
  end
end
