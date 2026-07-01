# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    module CLI
      def self.run
        server = Server.build
        warn "[stimulus-plumbers-mcp] server started (version #{VERSION})"
        ::MCP::Server::Transports::StdioTransport.new(server).open
      end
    end
  end
end
