# frozen_string_literal: true

require_relative "../../test_helper"

class GuideLoaderTest < Minitest::Test
  def setup
    @guide = StimulusPlumbers::MCP::GuideLoader.call
  end

  def test_returns_hash_of_markdown_strings
    %i[overview component controller tailwind theme].each do |key|
      assert @guide.key?(key), "guide missing :#{key}"
      assert_kind_of String, @guide[key]
      refute_empty @guide[key], "guide[:#{key}] should not be empty"
    end
  end

  def test_overview_is_markdown_overview
    assert_match(%r{# stimulus-plumbers}, @guide[:overview])
  end

  def test_overview_points_at_the_per_package_guides
    %w[guide://component guide://controller guide://tailwind guide://theme].each do |pointer|
      assert_includes @guide[:overview], pointer, "overview should point at #{pointer}"
    end
  end

  def test_overview_points_at_key_entry_points
    %w[
      get_component_helper
      get_field_as_values
      component://integration
      component://form/docs
      controller://index
      aria://reference
    ].each do |pointer|
      assert_includes @guide[:overview], pointer, "overview should point at #{pointer}"
    end
  end

  def test_overview_documents_resource_vs_tool_distinction
    assert_match(%r{Resources}, @guide[:overview])
    assert_match(%r{tools}, @guide[:overview])
  end

  def test_overview_documents_theme_authoring_audience
    assert_match(%r{theme author}i, @guide[:overview])
  end

  def test_overview_documents_uniform_error_contract
    assert_match(%r{Errors are uniform}i, @guide[:overview])
    assert_includes @guide[:overview], %({ "error": "..." })
    assert_match(%r{isError}, @guide[:overview])
  end

  def test_component_guide_names_level_2_as_recommended
    assert_match(%r{Level 2 — recommended}i, @guide[:component])
  end

  def test_controller_guide_documents_js_package_setup_for_non_rails_consumers
    assert_includes @guide[:controller], "npm install @stimulus-plumbers/controllers"
    assert_includes @guide[:controller], "application.register"
  end

  def test_tailwind_guide_documents_install_generator
    assert_includes @guide[:tailwind], "stimulus_plumbers:tailwind:install"
  end

  def test_theme_guide_documents_theme_subclassing
    assert_includes @guide[:theme], "Themes::Base"
  end
end
