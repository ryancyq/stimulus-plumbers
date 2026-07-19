# frozen_string_literal: true

require "test_helper"
require "stimulus_plumbers/tailwind/generators/animations_directive"

class TailwindGeneratorsAnimationsDirectiveTest < Minitest::Test
  def test_directive_builds_import_line_relative_to_the_css_file_directory
    destination_root = "/app"
    css_dir  = "/app/assets/stylesheets"
    expected = Pathname.new("#{destination_root}/app/assets/stylesheets/stimulus_plumbers/tailwind/animations.css")
                       .relative_path_from(Pathname.new(css_dir))
    expected = "./#{expected}" unless expected.to_s.start_with?(".", "/")

    assert_equal(
      %(@import "#{expected}";),
      StimulusPlumbers::Tailwind::Generators::AnimationsDirective.directive(from: css_dir, destination_root: destination_root)
    )
  end

  def test_anchor_pattern_matches_the_tokens_css_import_line
    assert_match(
      StimulusPlumbers::Tailwind::Generators::AnimationsDirective.anchor_pattern,
      %(@import "../stimulus_plumbers/tokens.css";)
    )
  end

  def test_anchor_pattern_does_not_match_an_unrelated_import
    refute_match(
      StimulusPlumbers::Tailwind::Generators::AnimationsDirective.anchor_pattern,
      %(@import "tailwindcss";)
    )
  end

  def test_stale_pattern_matches_a_prior_import_from_a_different_gem_path
    old_path = "/old/gems/stimulus_plumbers_tailwind-0.0.1/app/assets/stylesheets/stimulus_plumbers/tailwind/animations.css"
    old_line = %(@import "#{old_path}";)

    assert_match StimulusPlumbers::Tailwind::Generators::AnimationsDirective.stale_pattern, old_line
  end

  def test_stale_pattern_does_not_match_an_unrelated_import
    refute_match StimulusPlumbers::Tailwind::Generators::AnimationsDirective.stale_pattern, %(@import "tailwindcss";)
  end
end
