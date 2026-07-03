# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    class AriaLoader
      FILENAME = "ARIA.md"

      class << self
        def call
          path = resolved_path
          path ? File.read(path) : ""
        end

        private

        def resolved_path
          aria_paths.find { |p| File.exist?(p) }
        end

        def aria_paths
          [
            # 1. Monorepo dev checkout — the root file is the freshest copy while working locally.
            File.expand_path(File.join(__dir__, "../../../../..", FILENAME)),
            # 2. gem exec — vendored into the rails gem at release time (bin/release).
            GemVendorPath.resolve(FILENAME)
          ].compact
        end
      end
    end
  end
end
