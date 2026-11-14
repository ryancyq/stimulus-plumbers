# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    class ControllerDocsLoader
      REPO_DIR = "stimulus-plumbers/docs/component"

      class << self
        def docs_dir
          @docs_dir ||= resolve_docs_dir
        end

        def call
          Dir[File.join(docs_dir, "*.md")].to_h do |path|
            name = File.basename(path, ".md")
            [name.to_sym, DocLinks.rewrite(File.read(path), source: "#{REPO_DIR}/#{name}.md")]
          end
        end

        private

        def resolve_docs_dir
          # 1. Monorepo dev checkout — the JS package's own docs are freshest while working locally.
          dev_path = File.expand_path(File.join(__dir__, "../../../../..", "stimulus-plumbers", "docs", "component"))
          return dev_path if Dir.exist?(dev_path)

          # 2. gem exec — vendored into the rails gem at release time, under vendor/controller/docs/
          # (mirrors the MCP server's controller:// resource namespace).
          GemVendorPath.resolve("controller", "docs") || dev_path
        end
      end
    end
  end
end
