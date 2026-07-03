# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    module Server
      PLUGINS = [
        Plugins::ComponentDocs,
        Plugins::ComponentSchema,
        Plugins::ComponentTheme,

        Plugins::ControllerDocs,
        Plugins::ControllerSchema,

        Plugins::Icons,
        Plugins::Tailwind,

        Plugins::Aria,
        Plugins::Guide,
        Plugins::Versions
      ].freeze

      INSTRUCTIONS = "Use these resources and tools for accurate API references when " \
                     "generating Rails/ERB view code with the stimulus-plumbers UI library. " \
                     "Read guide://overview first for a map of the form/view/stimulus API."

      def self.build
        store = build_store
        report_sources(store)

        server = new_server
        server.resources_read_handler do |params|
          PLUGINS.lazy.filter_map { |plugin| plugin.read(params[:uri], store) }.first ||
            unknown_resource(params[:uri])
        end
        PLUGINS.each { |plugin| plugin.register_tools(server, store) }
        server
      end

      def self.build_store
        PLUGINS.to_h { |plugin| [plugin.loader_key, plugin.loader.call] }
      end

      def self.unknown_resource(uri)
        message = "unknown resource: #{uri} — read guide://overview for a map of available resources"
        [{ uri: uri, mimeType: "application/json", text: JSON.generate(error: message) }]
      end

      def self.new_server
        ::MCP::Server.new(
          name:               "stimulus-plumbers",
          version:            StimulusPlumbers::MCP::VERSION,
          instructions:       INSTRUCTIONS,
          resources:          PLUGINS.flat_map(&:static_resources),
          resource_templates: PLUGINS.flat_map(&:dynamic_resource_templates)
        )
      end

      # Loaders fail soft (sibling paths may be absent), so report what resolved
      # and warn loudly on any empty source instead of starting silently wrong.
      def self.report_sources(store)
        summary = store.map { |key, value| "#{key}=#{source_size(value)}" }.join(" ")
        StimulusPlumbers::Logger.info("sources: #{summary}")
        store.each_key do |key|
          StimulusPlumbers::Logger.warn("source '#{key}' is empty") if empty_source?(store[key])
        end
      end

      def self.source_size(value)
        case value
        when String     then value.empty? ? 0 : "ok"
        when Hash       then value.key?(:components) ? value[:components].size : value.size
        when Enumerable then value.size
        else value.nil? ? 0 : 1
        end
      end

      def self.empty_source?(value)
        content = value.is_a?(Hash) && value.key?(:components) ? value[:components] : value
        content.respond_to?(:empty?) && content.empty?
      end
    end
  end
end
