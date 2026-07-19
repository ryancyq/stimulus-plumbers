# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    module Plugins
      # Plugin contract: required members raise NotImplementedError; optional members have defaults.
      class Base
        # Returned by a tool block to signal not-found (see text_tool).
        NotFound = Struct.new(:message)

        class << self
          def loader_key
            raise NotImplementedError, "#{name} must define .loader_key"
          end

          def loader
            raise NotImplementedError, "#{name} must define .loader"
          end

          def read(_uri, _store)
            raise NotImplementedError, "#{name} must define .read"
          end

          def static_resources
            []
          end

          def dynamic_resource_templates
            []
          end

          def register_tools(_server, _store)
          end

          def not_found(message)
            NotFound.new(message)
          end

          def json_resource(uri, data)
            [{ uri: uri, mimeType: "application/json", text: JSON.generate(data) }]
          end

          def text_resource(uri, mime_type, text)
            [{ uri: uri, mimeType: mime_type, text: text }]
          end

          # Declaring **args makes the MCP gem inject :server_context, which tool blocks don't want — drop it.
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
end
