# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    module Plugins
      class ComponentDocs < Base
        class << self
          def loader_key = :component_docs

          def loader = ComponentDocsLoader

          def dynamic_resource_templates
            [
              ::MCP::ResourceTemplate.new(
                uri_template: "component://{name}/docs",
                name:         "component-docs",
                description:  "Full markdown documentation and ERB examples for a component",
                mime_type:    "text/markdown"
              ),
              ::MCP::ResourceTemplate.new(
                uri_template: "component://{name}/helper",
                name:         "component-helper",
                description:  "Full sp_ helper option surface: keyword options with defaults and slot methods",
                mime_type:    "application/json"
              )
            ].freeze
          end

          def read(uri, store)
            docs = store[:component_docs]

            case uri
            when %r{\Acomponent://([^/]+)/docs\z}
              doc = docs[Regexp.last_match(1).to_sym]
              doc ? text_resource(uri, "text/markdown", doc[:content]) : missing(uri, Regexp.last_match(1))
            when %r{\Acomponent://([^/]+)/helper\z}
              doc = docs[Regexp.last_match(1).to_sym]
              doc ? json_resource(uri, doc[:signature]) : missing(uri, Regexp.last_match(1))
            end
          end

          def register_tools(server, store)
            docs = store[:component_docs]

            register_list_component_docs(server, docs)
            register_get_component_examples(server, docs)
            register_get_component_helper(server, docs)
          end

          private

          def missing(uri, name)
            json_resource(uri, { error: "no documentation for: #{name}" })
          end

          def register_list_component_docs(server, docs)
            text_tool(
              server,
              name:        "list_component_docs",
              description: "Lists components that have markdown docs (component://{name}/docs) and " \
                           "helper signatures (component://{name}/helper)"
            ) do
              JSON.generate(docs.keys)
            end
          end

          def register_get_component_examples(server, docs)
            text_tool(
              server,
              name:         "get_component_examples",
              description:  "Returns ERB usage examples for a component from the documentation",
              input_schema: { properties: { name: { type: "string" } }, required: ["name"] }
            ) do |name:|
              examples = docs[name.to_sym]&.dig(:examples) || []
              examples.empty? ? not_found("no examples for: #{name}") : examples.join("\n\n")
            end
          end

          def register_get_component_helper(server, docs)
            text_tool(
              server,
              name:         "get_component_helper",
              description:  "Returns the full sp_ helper surface for a component: keyword options with " \
                            "defaults plus slot methods (e.g. icon_leading, card.with_action). For themed " \
                            "params/controllers use get_component_schema",
              input_schema: { properties: { name: { type: "string" } }, required: ["name"] }
            ) do |name:|
              doc = docs[name.to_sym]
              doc ? JSON.generate(doc[:signature]) : not_found("no documentation for: #{name}")
            end
          end
        end
      end
    end
  end
end
