# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    module Server
      PLUGINS = [
        Plugins::Guide,
        Plugins::Schema,
        Plugins::Docs,
        Plugins::Stimulus,
        Plugins::Theme,
        Plugins::Tailwind
      ].freeze

      INSTRUCTIONS = "Use these resources and tools for accurate API references when " \
                     "generating Rails/ERB view code with the stimulus-plumbers UI library. " \
                     "Read guide://overview first for a map of the form/view/stimulus API."

      def self.build
        store = PLUGINS.to_h { |plugin| [plugin::LOADER_KEY, plugin::LOADER.call] }
        report_sources(store)

        server = new_server
        server.resources_read_handler do |params|
          PLUGINS.lazy.filter_map { |plugin| plugin.read(params[:uri], store) }.first || []
        end
        PLUGINS.each { |plugin| plugin.register_tools(server, store) }
        server
      end

      def self.new_server
        ::MCP::Server.new(
          name:               "stimulus-plumbers",
          version:            StimulusPlumbersMcp::VERSION,
          instructions:       INSTRUCTIONS,
          resources:          PLUGINS.flat_map { |p| p::STATIC_RESOURCES },
          resource_templates: PLUGINS.flat_map { |p| p::DYNAMIC_RESOURCE_TEMPLATES }
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
