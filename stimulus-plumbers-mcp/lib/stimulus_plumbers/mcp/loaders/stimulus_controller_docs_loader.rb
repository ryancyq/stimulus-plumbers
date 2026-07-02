# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    class StimulusControllerDocsLoader
      def self.docs_dir
        @docs_dir ||= resolve_docs_dir
      end

      def self.resolve_docs_dir
        # 1. Monorepo dev checkout — the JS package's own docs are freshest while working locally.
        dev_path = File.expand_path(File.join(__dir__, "../../../../..", "stimulus-plumbers", "docs", "component"))
        return dev_path if Dir.exist?(dev_path)

        # 2. gem exec — vendored into the rails gem at release time (bin/release).
        gem_dir = Gem::Specification.find_by_name("stimulus_plumbers").gem_dir
        File.join(gem_dir, "vendor", "controller-docs")
      rescue Gem::MissingSpecError
        dev_path
      end
      private_class_method :resolve_docs_dir

      def self.call
        Dir[File.join(docs_dir, "*.md")].to_h do |path|
          [File.basename(path, ".md").to_sym, File.read(path)]
        end
      end
    end
  end
end
