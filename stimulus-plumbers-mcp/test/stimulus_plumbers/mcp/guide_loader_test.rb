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
    assert_match(%r{npm install .*@stimulus-plumbers/controllers}, @guide[:controller])
    assert_includes @guide[:controller], "application.register"
  end

  # The setup code must be in the guide itself — a third-party client cannot follow a README link.
  def test_controller_guide_inlines_the_import_and_register_calls
    assert_match(%r{^import \{ Application \} from '@hotwired/stimulus'}, @guide[:controller])
    assert_match(%r{from '@stimulus-plumbers/controllers'}, @guide[:controller])
    assert_match(%r{application\.register\('popover', PopoverController\)}, @guide[:controller])
  end

  # A guide that names a tool must spell its argument the way the tool's input schema does,
  # otherwise a tool-using client guesses.
  def test_guides_call_tools_with_their_real_parameter_names
    known = { "get_field_as_values" => "builder_method:", "get_field_as_controller" => "as:" }
    known.default = "name:"

    @guide.each do |key, markdown|
      markdown.scan(%r{`((?:get|list)_\w+)\(([^)]*)\)`}) do |tool, args|
        next if args.empty?

        assert_match(
          %r{\A#{Regexp.escape(known[tool])}},
          args,
          "guide[:#{key}] calls #{tool} with (#{args}), expected #{known[tool]}"
        )
      end
    end
  end

  def test_component_guide_documents_a_self_contained_quickstart
    assert_match(%r{gem "stimulus_plumbers"}, @guide[:component])
    assert_includes @guide[:component], "bin/rails generate stimulus_plumbers:install"
    assert_includes @guide[:component], "default_form_builder"
    assert_match(%r{f\.field :email, as: :email}, @guide[:component])
  end

  def test_tailwind_guide_documents_install_generator
    assert_includes @guide[:tailwind], "stimulus_plumbers:tailwind:install"
  end

  def test_theme_guide_documents_theme_subclassing
    assert_includes @guide[:theme], "Themes::Base"
  end
end
