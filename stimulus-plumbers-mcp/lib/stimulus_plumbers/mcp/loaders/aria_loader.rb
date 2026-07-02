# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    class AriaLoader
      FILENAME = "ARIA.md"

      def self.call
        path = resolved_path
        path ? File.read(path) : ""
      end

      def self.resolved_path
        aria_paths.find { |p| File.exist?(p) }
      end

      def self.aria_paths
        [
          # 1. Monorepo dev checkout — the root file is the freshest copy while working locally.
          File.expand_path(File.join(__dir__, "../../../../..", FILENAME)),
          # 2. gem exec — vendored into the rails gem at release time (bin/release).
          gem_vendor_path
        ].compact
      end

      def self.gem_vendor_path
        gem_dir = Gem::Specification.find_by_name("stimulus_plumbers").gem_dir
        File.join(gem_dir, "vendor", FILENAME)
      rescue Gem::MissingSpecError
        nil
      end

      private_class_method :resolved_path, :aria_paths, :gem_vendor_path
    end
  end
end
