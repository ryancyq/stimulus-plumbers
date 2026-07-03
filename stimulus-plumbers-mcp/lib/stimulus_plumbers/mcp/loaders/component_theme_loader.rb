# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    class ComponentThemeLoader
      class << self
        def call
          {
            base_doc:   base_doc,
            components: extract_interface
          }
        end

        private

        # Same file ComponentDocsLoader already serves at component://theme/docs — avoids a duplicate heredoc.
        def base_doc
          path = File.join(ComponentDocsLoader.docs_dir, "theme.md")
          File.exist?(path) ? File.read(path) : ""
        end

        def extract_interface
          Themes::Base::SCHEMA.each_with_object({}) do |(key, params), result|
            result[key] = {
              method:  "#{key}_classes",
              params:  params.transform_values { |meta| format_param(meta) },
              returns: "{ classes: String }"
            }
          end
        end

        def format_param(meta)
          valid = meta[:validate]
          entry = { default: meta[:default] }
          entry[:valid] = valid.to_a if valid.respond_to?(:to_a)
          entry
        end
      end
    end
  end
end
