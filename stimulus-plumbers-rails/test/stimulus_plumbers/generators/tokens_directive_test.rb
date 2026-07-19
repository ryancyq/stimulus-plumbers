# frozen_string_literal: true

require "test_helper"
require "stimulus_plumbers/generators/tokens_directive"

class GeneratorsTokensDirectiveTest < Minitest::Test
  def test_directive_builds_import_line_relative_to_the_css_file_directory
    destination_root = "/app"
    css_dir  = "/app/assets/stylesheets"
    expected = Pathname.new("#{destination_root}/app/assets/stylesheets/stimulus_plumbers/tokens.css")
                       .relative_path_from(Pathname.new(css_dir))
    expected = "./#{expected}" unless expected.to_s.start_with?(".", "/")

    assert_equal(
      %(@import "#{expected}";),
      StimulusPlumbers::Generators::TokensDirective.directive(from: css_dir, destination_root: destination_root)
    )
  end

  def test_stale_pattern_matches_a_prior_import_from_a_different_gem_path
    old_line = %(@import "/old/gems/stimulus_plumbers-0.0.1/app/assets/stylesheets/stimulus_plumbers/tokens.css";)

    assert_match StimulusPlumbers::Generators::TokensDirective.stale_pattern, old_line
  end

  def test_stale_pattern_does_not_match_an_unrelated_import
    refute_match StimulusPlumbers::Generators::TokensDirective.stale_pattern, %(@import "tailwindcss";)
  end
end
