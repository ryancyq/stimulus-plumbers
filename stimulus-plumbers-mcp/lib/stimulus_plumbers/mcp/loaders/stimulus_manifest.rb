# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    class StimulusManifest
      MANIFEST_PATH = File.expand_path(
        File.join(__dir__, "../../../../..", "stimulus-plumbers", "dist", "controllers.manifest.json")
      ).freeze

      def self.call
        unless File.exist?(MANIFEST_PATH)
          StimulusPlumbers::Logger.warn(
            "controllers.manifest.json not found at #{MANIFEST_PATH}. " \
            "Run `node --run build:manifest` in stimulus-plumbers/ to generate it."
          )
          return {}
        end

        JSON.parse(File.read(MANIFEST_PATH))
      end
    end
  end
end
