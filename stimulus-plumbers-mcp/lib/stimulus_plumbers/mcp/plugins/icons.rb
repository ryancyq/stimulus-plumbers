# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    module Plugins
      class Icons < Base
        class << self
          def loader_key = :icons

          def loader = IconsLoader

          def static_resources
            [
              ::MCP::Resource.new(
                uri:         "component://icons",
                name:        "icons",
                description: "All available icon names bundled with the Tailwind theme",
                mime_type:   "application/json"
              )
            ].freeze
          end

          def read(uri, store)
            return unless uri == "component://icons"

            json_resource(uri, store[:icons])
          end

          def register_tools(server, store)
            text_tool(
              server,
              name:        "list_icons",
              description: "Lists all available icon names bundled with the Tailwind theme"
            ) do
              JSON.generate(store[:icons])
            end
          end
        end
      end
    end
  end
end
