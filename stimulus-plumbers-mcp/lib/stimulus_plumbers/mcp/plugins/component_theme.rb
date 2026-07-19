# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    module Plugins
      class ComponentTheme < Base
        class << self
          def loader_key
            :component_theme
          end

          def loader
            ComponentThemeLoader
          end

          def static_resources
            [
              ::MCP::Resource.new(
                uri:         "component://theme/base",
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
          end

          def dynamic_resource_templates
            [
              ::MCP::ResourceTemplate.new(
                uri_template: "component://{name}/theme",
                name:         "component-theme-interface",
                description:  "Method name, param signature, and return contract for implementing a component in a custom theme",
                mime_type:    "application/json"
              )
            ].freeze
          end

          def read(uri, store)
            theme = store[:component_theme]

            case uri
            when "component://theme/base"
              text_resource(uri, "text/markdown", theme[:base_doc])
            when "component://theme"
              json_resource(uri, theme[:components].keys)
            when %r{\Acomponent://([^/]+)/theme\z}
              key = Regexp.last_match(1).to_sym
              json_resource(uri, theme[:components][key] || { error: "unknown component: #{key}" })
            end
          end

          def register_tools(server, store)
            theme = store[:component_theme]

            register_list_component_themes(server, theme)
            register_get_component_theme(server, theme)
          end

          private

          def register_list_component_themes(server, theme)
            text_tool(
              server,
              name:        "list_component_themes",
              description: "Lists all component keys that can be implemented in a custom theme"
            ) do
              JSON.generate(theme[:components].keys)
            end
          end

          def register_get_component_theme(server, theme)
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
end
