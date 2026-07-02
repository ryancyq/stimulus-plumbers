# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    class SourceVersionsLoader
      GEM_SOURCES = {
        schema:   "stimulus_plumbers",
        docs:     "stimulus_plumbers",
        theme:    "stimulus_plumbers",
        tailwind: "stimulus_plumbers_tailwind"
      }.freeze

      def self.call
        GEM_SOURCES.transform_values { |gem_name| { version: gem_version(gem_name) } }
                   .merge(stimulus: stimulus_source)
      end

      def self.gem_version(gem_name)
        Gem::Specification.find_by_name(gem_name).version.to_s
      rescue Gem::MissingSpecError
        nil
      end

      def self.stimulus_source
        path = StimulusManifestLoader.resolved_path
        return { version: nil, resolved_from: nil } unless path

        { version: npm_version(path), resolved_from: resolved_from(path) }
      end

      # No package.json next to the gem vendor path — fall back to the gem's own version.
      def self.npm_version(manifest_path)
        package_json = File.join(File.dirname(manifest_path), "..", "package.json")
        return gem_version("stimulus_plumbers") unless File.exist?(package_json)

        JSON.parse(File.read(package_json))["version"]
      end

      def self.resolved_from(manifest_path)
        case manifest_path
        when %r{node_modules} then "node_modules"
        when %r{vendor}       then "stimulus_plumbers gem vendor"
        else "monorepo sibling dist/"
        end
      end

      private_class_method :gem_version, :stimulus_source, :npm_version, :resolved_from
    end
  end
end
