# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    module Plugins
      # Shares the controller:// scheme with Plugins::Stimulus, distinguished by the
      # docs/ path segment (Plugins::Stimulus is per-identifier schema data; docs/ is
      # narrative markdown, grouped by controller family, not individual identifier).
      module StimulusControllerDocs
        extend Base

        LOADER_KEY = :stimulus_docs
        LOADER     = StimulusControllerDocsLoader

        STATIC_RESOURCES = [
          ::MCP::Resource.new(
            uri:         "controller://docs",
            name:        "controller-docs-index",
            description: "Index of JS controller narrative docs, grouped by controller family " \
                         "(e.g. :calendar covers calendar-month/-year/-decade)",
            mime_type:   "application/json"
          )
        ].freeze

        DYNAMIC_RESOURCE_TEMPLATES = [
          ::MCP::ResourceTemplate.new(
            uri_template: "controller://docs/{name}",
            name:         "controller-doc",
            description:  "Narrative usage doc for a controller family, for plain-JS/Hotwire consumers " \
                          "without Rails helpers",
            mime_type:    "text/markdown"
          )
        ].freeze

        def self.read(uri, store)
          docs = store[:stimulus_docs]

          case uri
          when "controller://docs"
            json_resource(uri, docs.keys)
          when %r{\Acontroller://docs/(.+)\z}
            key = Regexp.last_match(1).to_sym
            docs[key] ? text_resource(uri, "text/markdown", docs[key]) : missing(uri, key)
          end
        end

        def self.missing(uri, key)
          json_resource(uri, { error: "no controller docs for: #{key}" })
        end
        private_class_method :missing

        def self.register_tools(server, store)
          docs = store[:stimulus_docs]

          text_tool(
            server,
            name:        "list_controller_docs",
            description: "Lists controller doc families available at controller://docs/{name} — " \
                         "grouped by family, not individual controller identifier"
          ) do
            JSON.generate(docs.keys)
          end

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
