# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    class GuideLoader
      OVERVIEW_PATH = File.expand_path("guide/overview.md", __dir__).freeze

      def self.call
        return "" unless File.exist?(OVERVIEW_PATH)

        File.read(OVERVIEW_PATH)
      end
    end
  end
end
