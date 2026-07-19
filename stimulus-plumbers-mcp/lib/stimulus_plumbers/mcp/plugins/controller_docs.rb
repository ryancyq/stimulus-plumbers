# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    module Plugins
      # Shares the controller:// scheme with Plugins::ControllerSchema, distinguished by the
      # docs/ path segment (ControllerSchema is per-identifier schema data; docs/ is
      # narrative markdown, grouped by controller family, not individual identifier).
      class ControllerDocs < Base
        class << self
          def loader_key
            :controller_docs
          end

          def loader
            ControllerDocsLoader
          end

          def static_resources
            [
              ::MCP::Resource.new(
                uri:         "controller://docs",
                name:        "controller-docs-index",
                description: "Index of JS controller narrative docs, grouped by controller family " \
                             "(e.g. :calendar covers calendar-month/-year/-decade)",
                mime_type:   "application/json"
              )
            ].freeze
          end

          def dynamic_resource_templates
            [
              ::MCP::ResourceTemplate.new(
                uri_template: "controller://docs/{name}",
                name:         "controller-doc",
                description:  "Narrative usage doc for a controller family, for plain-JS/Hotwire consumers " \
                              "without Rails helpers",
                mime_type:    "text/markdown"
              )
            ].freeze
          end

          def read(uri, store)
            docs = store[:controller_docs]

            case uri
            when "controller://docs"
              json_resource(uri, docs.keys)
            when %r{\Acontroller://docs/(.+)\z}
              key = Regexp.last_match(1).to_sym
              docs[key] ? text_resource(uri, "text/markdown", docs[key]) : missing(uri, key)
            end
          end

          def register_tools(server, store)
            docs = store[:controller_docs]

            register_list_controller_docs(server, docs)
            register_get_controller_docs(server, docs)
          end

          private

          def missing(uri, key)
            json_resource(uri, { error: "no controller docs for: #{key}" })
          end

          def register_list_controller_docs(server, docs)
            text_tool(
              server,
              name:        "list_controller_docs",
              description: "Lists controller doc families available at controller://docs/{name} — " \
                           "grouped by family, not individual controller identifier"
            ) do
              JSON.generate(docs.keys)
            end
          end

          def register_get_controller_docs(server, docs)
            text_tool(
              server,
              name:         "get_controller_docs",
              description:  "Returns the narrative usage doc for a controller family (e.g. \"calendar\", " \
                            "\"combobox\") — for individual controller targets/values/outlets use get_controller_schema",
              input_schema: { properties: { name: { type: "string" } }, required: ["name"] }
            ) do |name:|
              doc = docs[name.to_sym]
              doc || not_found("no controller docs for: #{name}")
            end
          end
        end
      end
    end
  end
end
