# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    module Plugins
      class Guide < Base
        GUIDE_NAMES = %w[component controller tailwind theme].freeze

        class << self
          def loader_key
            :guide
          end

          def loader
            GuideLoader
          end

          def static_resources
            [
              ::MCP::Resource.new(
                uri:         "guide://overview",
                name:        "overview",
                description: "Start here — how to build views and forms with stimulus-plumbers, with pointers " \
                             "to every tool/resource",
                mime_type:   "text/markdown"
              )
            ].freeze
          end

          def dynamic_resource_templates
            [
              ::MCP::ResourceTemplate.new(
                uri_template: "guide://{name}",
                name:         "guide",
                description:  "Per-package usage guide: component (Rails forms/views), controller " \
                              "(plain-JS/non-Rails setup), tailwind (Tailwind install/theming), theme " \
                              "(custom theme integration contract)",
                mime_type:    "text/markdown"
              )
            ].freeze
          end

          def read(uri, store)
            guide = store[:guide]

            case uri
            when "guide://overview"
              text_resource(uri, "text/markdown", guide[:overview])
            when %r{\Aguide://(#{GUIDE_NAMES.join("|")})\z}
              text_resource(uri, "text/markdown", guide[Regexp.last_match(1).to_sym])
            end
          end

          def register_tools(server, store)
            guide = store[:guide]

            register_list_guides(server)
            register_get_guide(server, guide)
          end

          private

          def register_list_guides(server)
            text_tool(
              server,
              name:        "list_guides",
              description: "Lists available per-package usage guides — see guide://overview for the full map"
            ) do
              JSON.generate(GUIDE_NAMES)
            end
          end

          def register_get_guide(server, guide)
            text_tool(
              server,
              name:         "get_guide",
              description:  "Returns a per-package usage guide: component (Rails forms/views), controller " \
                            "(plain-JS/non-Rails setup), tailwind (Tailwind install/theming), theme (custom " \
                            "theme integration contract)",
              input_schema: { properties: { name: { type: "string", enum: GUIDE_NAMES } }, required: ["name"] }
            ) do |name:|
              guide[name.to_sym] || not_found("unknown guide: #{name}")
            end
          end
        end
      end
    end
  end
end
