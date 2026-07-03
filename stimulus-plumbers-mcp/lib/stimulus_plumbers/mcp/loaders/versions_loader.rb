# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    class VersionsLoader
      class << self
        def call
          {
            component_docs:    component_docs_source,
            component_guide:   component_guide_source,
            component_schema:  component_schema_source,
            component_theme:   component_theme_source,

            controller_docs:   controller_docs_source,
            controller_guide:  controller_guide_source,
            controller_schema: controller_schema_source,

            icons:             icons_source,
            tailwind:          tailwind_source,
            tailwind_guide:    tailwind_guide_source
          }
        end

        private

        def gem_version(gem_name)
          Gem::Specification.find_by_name(gem_name).version.to_s
        rescue Gem::MissingSpecError
          nil
        end

        def component_docs_source
          { version: gem_version("stimulus_plumbers") }
        end

        def component_guide_source
          { version: gem_version("stimulus_plumbers") }
        end

        def component_schema_source
          { version: gem_version("stimulus_plumbers") }
        end

        def component_theme_source
          { version: gem_version("stimulus_plumbers") }
        end

        def controller_docs_source
          dir = ControllerDocsLoader.docs_dir
          return { version: nil, resolved_from: nil } unless dir && Dir.exist?(dir)

          { version: npm_package_version(File.join(dir, "..", "..")), resolved_from: npm_docs_resolved_from(dir) }
        end

        def controller_guide_source
          path = GuideLoader.controller_guide_path
          return { version: nil, resolved_from: nil } unless path && File.exist?(path)

          { version:       npm_package_version(File.join(File.dirname(path), "..")),
            resolved_from: npm_docs_resolved_from(path)
}
        end

        def controller_schema_source
          path = ControllerSchemaLoader.resolved_path
          return { version: nil, resolved_from: nil } unless path

          { version:       npm_package_version(File.join(File.dirname(path), "..")),
            resolved_from: controller_schema_resolved_from(path)
}
        end

        def controller_schema_resolved_from(path)
          case path
          when %r{node_modules} then "node_modules"
          when %r{vendor}       then "stimulus_plumbers gem vendor"
          else "monorepo sibling dist/"
          end
        end

        # Shared by controller_docs_source and controller_guide_source — both read from the same
        # npm package's docs/ tree, dev sibling checkout vs vendored into the rails gem.
        def npm_docs_resolved_from(path)
          path.include?("vendor") ? "stimulus_plumbers gem vendor" : "monorepo sibling stimulus-plumbers/docs"
        end

        # package_root is the npm package's own directory — no package.json there means a vendored
        # copy that didn't carry one along, so fall back to the wrapping gem's version.
        def npm_package_version(package_root)
          package_json = File.join(package_root, "package.json")
          return gem_version("stimulus_plumbers") unless File.exist?(package_json)

          JSON.parse(File.read(package_json))["version"]
        end

        def icons_source
          { version: gem_version("stimulus_plumbers_tailwind") }
        end

        def tailwind_source
          { version: gem_version("stimulus_plumbers_tailwind") }
        end

        def tailwind_guide_source
          { version: gem_version("stimulus_plumbers_tailwind") }
        end
      end
    end
  end
end
