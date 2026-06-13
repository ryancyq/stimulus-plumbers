# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    module Plugins
      # Shared contract + content helpers for plugins, which `extend` this.
      #
      # Each plugin defines: LOADER_KEY, LOADER, STATIC_RESOURCES,
      # DYNAMIC_RESOURCE_TEMPLATES, and read(uri, store). Tools are optional —
      # plugins with tools override register_tools, the rest inherit the no-op.
      module Base
        # Returned by a tool block to signal "not found" — rendered as an MCP
        # error response with a structured { error: } payload (see text_tool).
        NotFound = Struct.new(:message)

        def register_tools(_server, _store); end

        def not_found(message)
          NotFound.new(message)
        end

        # resources/read content for a JSON payload.
        def json_resource(uri, data)
          [{ uri: uri, mimeType: "application/json", text: JSON.generate(data) }]
        end

        # resources/read content for raw text (e.g. markdown).
        def text_resource(uri, mime_type, text)
          [{ uri: uri, mimeType: mime_type, text: text }]
        end

        # Define a tool whose block returns the response text, or `not_found(msg)`
        # for a uniform error (isError + { error: } JSON). Declaring `**args` makes
        # the MCP gem inject :server_context, which tool blocks don't want — drop it.
        def text_tool(server, name:, description:, input_schema: nil, &block)
          server.define_tool(name: name, description: description, input_schema: input_schema) do |**args|
            args.delete(:server_context)
            result = block.call(**args)
            if result.is_a?(NotFound)
              ::MCP::Tool::Response.new([{ type: "text", text: JSON.generate(error: result.message) }], error: true)
            else
              ::MCP::Tool::Response.new([{ type: "text", text: result }])
            end
          end
        end
      end
    end
  end
end
