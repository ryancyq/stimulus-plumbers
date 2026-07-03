# frozen_string_literal: true

require "test_helper"
require "stimulus_plumbers/tailwind/generators/sources_directive"

class TailwindGeneratorsSourcesDirectiveTest < Minitest::Test
  def test_directive_builds_source_line_relative_to_the_css_file_directory
    gem_lib_dir = "#{Gem.loaded_specs["stimulus_plumbers_tailwind"].gem_dir}/lib"
    css_dir     = "/app/assets/stylesheets"
    expected    = Pathname.new(gem_lib_dir).relative_path_from(Pathname.new(css_dir))

    assert_equal(
      %(@source "#{expected}/**/*.rb";),
      StimulusPlumbers::Tailwind::Generators::SourcesDirective.directive(from: css_dir)
    )
  end

  def test_anchor_pattern_matches_the_tailwindcss_import_line
    assert_match StimulusPlumbers::Tailwind::Generators::SourcesDirective.anchor_pattern, %(@import "tailwindcss";)
  end

  def test_stale_pattern_matches_a_prior_source_from_a_different_gem_path
    old_line = %(@source "/old/gems/stimulus_plumbers_tailwind-0.0.1/lib/**/*.rb";)

    assert_match StimulusPlumbers::Tailwind::Generators::SourcesDirective.stale_pattern, old_line
  end

  def test_stale_pattern_does_not_match_an_unrelated_source
    refute_match StimulusPlumbers::Tailwind::Generators::SourcesDirective.stale_pattern, %(@source "./app/views/**/*.erb";)
  end
end
