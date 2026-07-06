# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    class ControllerSchemaLoader
      MANIFEST_FILENAME = "controllers.manifest.json"
      # Vendored as manifest.json — the "controllers" prefix is redundant once nested
      # under vendor/controller/ (mirrors the MCP server's controller:// namespace).
      VENDOR_FILENAME = "manifest.json"

      class << self
        def call
          path = resolved_path

          unless path
            StimulusPlumbers::Logger.warn(
              "controller manifest not found. Tried:\n" \
              "#{manifest_paths.map { |p| "  - #{p}" }.join("\n")}\n" \
              "Run `node --run build:manifest` in stimulus-plumbers/ to generate it."
            )
            return {}
          end

          controllers = JSON.parse(File.read(path))
          wiring = ComponentManifestLoader.call
          default_wiring = { "actions" => [], "listens" => [], "targets" => [], "values" => [] }

          controllers.transform_values { |data| data.merge("wiring" => wiring[data["identifier"]] || default_wiring) }
        end

        # Reused by VersionsLoader to report which fallback location resolved.
        def resolved_path
          manifest_paths.find { |p| File.exist?(p) }
        end

        private

        def manifest_paths
          [
            # 1. npm/yarn/bun project — version matches project lockfile
            File.join(Dir.pwd, "node_modules/@stimulus-plumbers/controllers/dist", MANIFEST_FILENAME),
            # 2. importmaps users — vendored in Rails gem at release time
            GemVendorPath.resolve("controller", VENDOR_FILENAME),
            # 3. Monorepo dev fallback
            File.expand_path(
              File.join(__dir__, "../../../../..", "stimulus-plumbers", "dist", MANIFEST_FILENAME)
            )
          ].compact
        end
      end
    end
  end
end
