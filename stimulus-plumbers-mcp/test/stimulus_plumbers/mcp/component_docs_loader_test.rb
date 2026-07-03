# frozen_string_literal: true

require_relative "../../test_helper"

class ComponentDocsLoaderTest < Minitest::Test
  def setup
    @docs = StimulusPlumbers::MCP::ComponentDocsLoader.call
  end

  def test_loads_known_doc_files
    %i[button form theme combobox calendar].each do |name|
      assert @docs.key?(name), "missing doc: #{name}"
    end
  end

  def test_each_doc_has_required_keys
    @docs.each do |name, doc|
      assert doc.key?(:content),   "#{name}: missing :content"
      assert doc.key?(:examples),  "#{name}: missing :examples"
      assert doc.key?(:signature), "#{name}: missing :signature"
      refute_empty doc[:content], "#{name}: content is empty"
    end
  end

  def button_options
    @docs[:button][:signature][:helpers].flat_map { |h| h[:options] }
  end

  def test_button_signature_includes_keyword_options
    names = button_options.map { |o| o[:option] }

    assert_includes names, "type"
    assert_includes names, "icon_leading"
  end

  def test_button_signature_captures_defaults
    type = button_options.find { |o| o[:option] == "type" }

    assert_equal ":default", type[:default]
  end

  def list_helper_options(prefix)
    helper = @docs[:list][:signature][:helpers].find { |h| h[:signature].start_with?(prefix) }
    helper[:options].map { |o| o[:option] }
  end

  def test_list_signature_groups_options_by_helper
    assert_includes list_helper_options("sp_list"), "heading_level"
    assert_includes list_helper_options("list.item"), "url"
    refute_includes list_helper_options("sp_list"), "url"
  end

  def test_card_signature_includes_slot_methods
    slots = @docs[:card][:signature][:slots].map { |s| s[:slot] }

    assert_includes slots, "card.with_action(text, url: nil)"
  end

  def test_card_signature_flags_block_required_slot
    with_body = @docs[:card][:signature][:slots].find { |s| s[:slot].start_with?("card.with_body") }

    assert with_body[:block], "card.with_body should be flagged block-required"
  end

  def test_button_doc_has_erb_examples
    refute_empty @docs[:button][:examples]
  end

  def test_form_doc_has_erb_examples
    refute_empty @docs[:form][:examples]
  end

  def test_examples_are_stripped_strings
    @docs[:button][:examples].each do |example|
      assert_instance_of String, example
      refute_match(%r{\A\s}, example, "example has leading whitespace")
      refute_match(%r{\s\z}, example, "example has trailing whitespace")
    end
  end

  def test_docs_dir_exists
    assert File.directory?(StimulusPlumbers::MCP::ComponentDocsLoader.docs_dir),
           "docs_dir does not exist: #{StimulusPlumbers::MCP::ComponentDocsLoader.docs_dir}"
  end

  def form_helpers
    @docs[:form][:signature][:helpers]
  end

  def test_bold_subheadings_are_composed_with_parent_heading
    signatures = form_helpers.map { |h| h[:signature] }

    assert_includes signatures, "f.field — Time"
    assert_includes signatures, "f.field — Select"
    assert_includes signatures, "f.field — Search"
  end

  def test_bold_subheading_does_not_leak_across_a_fenced_code_block
    combobox_dropdown = @docs[:combobox][:signature][:helpers].find { |h| h[:signature] == "sp_combobox_dropdown" }

    refute_nil combobox_dropdown,
               "sp_combobox_dropdown table should not be mislabeled with the preceding " \
               "'Option formats:' bold aside, which is separated from it by a code fence"
  end

  def test_bold_subheading_does_not_leak_to_a_second_table_under_the_same_heading
    select_options = form_helpers.find { |h| h[:signature] == "f.field — Select" }[:options].map { |o| o[:option] }
    search_options = form_helpers.find { |h| h[:signature] == "f.field — Search" }[:options].map { |o| o[:option] }

    assert_includes select_options, "include_blank"
    refute_includes search_options, "include_blank", "Select's options leaked into Search's table"
  end
end
