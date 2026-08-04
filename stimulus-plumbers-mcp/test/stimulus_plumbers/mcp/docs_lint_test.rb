# frozen_string_literal: true

require_relative "../../test_helper"

# Wrong table headers and broken links fail silently otherwise — get_component_helper
# just returns less than documented. Runs against every docs_dir the server serves.
class DocsLintTest < Minitest::Test
  DOC_DIRS = [
    StimulusPlumbers::MCP::ComponentDocsLoader.docs_dir,
    StimulusPlumbers::MCP::ControllerDocsLoader.docs_dir
  ].freeze

  RECOGNIZED_TABLE_HEADERS = ["Option", "Slot method"].freeze

  def each_doc
    DOC_DIRS.each do |dir|
      Dir[File.join(dir, "*.md")].each { |path| yield path, File.read(path) }
    end
  end

  def test_option_and_slot_like_table_headers_are_recognized_exactly
    each_doc do |path, content|
      StimulusPlumbers::MCP::DocsTableParser.tables_with_headings(content).each do |table|
        header = table[:header]&.first.to_s

        next unless header.downcase.match?(%r{\boption\b|\bslot\b})
        next if RECOGNIZED_TABLE_HEADERS.include?(header)

        flunk "#{File.basename(path)}: table header #{header.inspect} looks like an option/slot " \
              "table but isn't recognized by DocsTableParser (expected exactly #{RECOGNIZED_TABLE_HEADERS}) " \
              "— its rows will silently disappear from get_component_helper/get_controller_docs"
      end
    end
  end

  def test_option_tables_name_a_description_column
    each_doc do |path, content|
      StimulusPlumbers::MCP::DocsTableParser.tables_with_headings(content).each do |table|
        next unless table[:header].first == "Option"

        assert_includes table[:header],
                        "Description",
                        "#{File.basename(path)}: option table #{table[:header].inspect} has no Description column"
      end
    end
  end

  def test_relative_markdown_links_resolve_to_real_files
    each_doc do |path, content|
      content.scan(%r{\[[^\]]*\]\(([^)]+)\)}).each do |(target)|
        next if target.match?(%r{\A[a-z]+://}i)

        file_part = target.split("#").first
        next if file_part.nil? || file_part.empty?

        resolved = File.expand_path(file_part, File.dirname(path))

        assert_path_exists resolved,
                           "#{File.basename(path)}: link target #{target.inspect} does not resolve " \
                           "(resolved to #{resolved})"
      end
    end
  end
end
