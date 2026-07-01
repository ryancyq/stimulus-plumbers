# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    class StimulusManifestLoader
      MANIFEST_FILENAME = "controllers.manifest.json"

      def self.call
        paths = manifest_paths
        path  = paths.find { |p| File.exist?(p) }

        unless path
          StimulusPlumbers::Logger.warn(
            "#{MANIFEST_FILENAME} not found. Tried:\n" \
            "#{paths.map { |p| "  - #{p}" }.join("\n")}\n" \
            "Run `node --run build:manifest` in stimulus-plumbers/ to generate it."
          )
          return {}
        end

        JSON.parse(File.read(path))
      end

      def self.manifest_paths
        [
          # 1. npm/yarn/bun project — version matches project lockfile
          File.join(Dir.pwd, "node_modules/@stimulus-plumbers/controllers/dist", MANIFEST_FILENAME),
          # 2. importmaps users — vendored in Rails gem at release time
          gem_vendor_path,
          # 3. Monorepo dev fallback
          File.expand_path(
            File.join(__dir__, "../../../../..", "stimulus-plumbers", "dist", MANIFEST_FILENAME)
          )
        ].compact
      end

      def self.gem_vendor_path
        gem_dir = Gem::Specification.find_by_name("stimulus_plumbers").gem_dir
        File.join(gem_dir, "vendor", MANIFEST_FILENAME)
      rescue Gem::MissingSpecError
        nil
      end

      private_class_method :manifest_paths, :gem_vendor_path
    end
  end
end
