# frozen_string_literal: true

require_relative "../../test_helper"

class GuideLoaderTest < Minitest::Test
  def setup
    @overview = StimulusPlumbers::MCP::GuideLoader.call
  end

  def test_returns_markdown_overview
    assert_kind_of String, @overview
    assert_match(%r{# stimulus-plumbers}, @overview)
  end

  def test_points_at_the_key_entry_points
    %w[f.field get_helper_signature get_field_types schema://stimulus docs://components/form].each do |pointer|
      assert_includes @overview, pointer, "overview should point at #{pointer}"
    end
  end

  def test_names_level_2_as_recommended
    assert_match(%r{Level 2 — recommended}i, @overview)
  end

  def test_documents_resource_vs_tool_distinction
    assert_match(%r{Resources}, @overview)
    assert_match(%r{tools}, @overview)
  end

  def test_documents_theme_authoring_audience
    assert_match(%r{theme author}i, @overview)
  end

  def test_documents_uniform_error_contract
    assert_match(%r{Errors are uniform}i, @overview)
    assert_includes @overview, %({ "error": "..." })
    assert_match(%r{isError}, @overview)
  end

  def test_documents_tailwind_install_generator
    assert_includes @overview, "stimulus_plumbers_tailwind:install"
    assert_includes @overview, "TAILWIND_CSS_FILE"
  end
end
