# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    class ComponentDocsLoader
      class << self
        def docs_dir
          @docs_dir ||= resolve_docs_dir
        end

        def call
          Dir[File.join(docs_dir, "*.md")].each_with_object({}) do |path, result|
            name = File.basename(path, ".md").to_sym
            content = File.read(path)
            result[name] = {
              content:   content,
              examples:  extract_erb_examples(content),
              signature: DocsTableParser.call(content)
            }
          end
        end

        private

        def resolve_docs_dir
          gem_dir = Gem::Specification.find_by_name("stimulus_plumbers").gem_dir
          File.join(gem_dir, "docs/component")
        rescue Gem::MissingSpecError
          File.expand_path("../../../../../stimulus-plumbers-rails/docs/component", __dir__)
        end

        def extract_erb_examples(content)
          content.scan(%r{```erb\n(.*?)```}m).map(&:first).map(&:strip)
        end
      end
    end
  end
end
