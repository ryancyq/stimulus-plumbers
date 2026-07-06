# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    # Reads the stimulus_plumbers gem's own generated wiring manifest (vendor/component/manifest.json).
    # Unlike ControllerSchemaLoader, this never crosses ecosystems — stimulus_plumbers is always
    # installed alongside this gem (hard runtime dependency), so there's no node_modules-style path.
    class ComponentManifestLoader
      MANIFEST_FILENAME = "manifest.json"

      class << self
        def call
          path = resolved_path

          unless path
            StimulusPlumbers::Logger.warn(
              "component manifest not found. Tried:\n" \
              "#{manifest_paths.map { |p| "  - #{p}" }.join("\n")}\n" \
              "Run `bundle exec rake build:manifest` in stimulus-plumbers-rails/ to generate it."
            )
            return {}
          end

          JSON.parse(File.read(path))
        end

        def resolved_path
          manifest_paths.find { |p| File.exist?(p) }
        end

        private

        def manifest_paths
          [
            # 1. gem exec / installed gem — vendored at release time
            GemVendorPath.resolve("component", MANIFEST_FILENAME),
            # 2. Monorepo dev fallback
            File.expand_path(
              File.join(__dir__, "../../../../..", "stimulus-plumbers-rails", "vendor", "component", MANIFEST_FILENAME)
            )
          ].compact
        end
      end
    end
  end
end
