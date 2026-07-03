# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    class GuideLoader
      OVERVIEW_PATH = File.expand_path("guide.md", __dir__).freeze

      class << self
        def call
          {
            overview:   read_file(OVERVIEW_PATH),
            component:  read_file(component_guide_path),
            controller: read_file(controller_guide_path),
            tailwind:   read_file(tailwind_guide_path),
            theme:      read_file(File.join(ComponentDocsLoader.docs_dir, "theme.md"))
          }
        end

        # Reused by VersionsLoader to report which fallback location resolved.
        def controller_guide_path
          # 1. Monorepo dev checkout — the JS package's own docs are freshest while working locally.
          dev_path = File.expand_path(File.join(__dir__, "../../../../..", "stimulus-plumbers", "docs", "guide.md"))
          return dev_path if File.exist?(dev_path)

          # 2. gem exec — vendored into the rails gem at release time, under vendor/controller/guide.md.
          GemVendorPath.resolve("controller", "guide.md")
        end

        private

        def read_file(path)
          path && File.exist?(path) ? File.read(path) : ""
        end

        def component_guide_path
          gem_dir = Gem::Specification.find_by_name("stimulus_plumbers").gem_dir
          File.join(gem_dir, "docs/guide.md")
        rescue Gem::MissingSpecError
          File.expand_path("../../../../../stimulus-plumbers-rails/docs/guide.md", __dir__)
        end

        def tailwind_guide_path
          gem_dir = Gem::Specification.find_by_name("stimulus_plumbers_tailwind").gem_dir
          File.join(gem_dir, "docs/guide.md")
        rescue Gem::MissingSpecError
          File.expand_path("../../../../../stimulus-plumbers-tailwind/docs/guide.md", __dir__)
        end
      end
    end
  end
end
