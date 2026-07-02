# frozen_string_literal: true

require "test_helper"
require "stimulus_plumbers/generators/tokens_directive"

class GeneratorsTokensDirectiveTest < Minitest::Test
  def test_directive_builds_import_line_from_installed_gem_dir
    gem_dir = Gem.loaded_specs["stimulus_plumbers"].gem_dir

    assert_equal(
      %(@import "#{gem_dir}/app/assets/stylesheets/stimulus_plumbers/tokens.css";),
      StimulusPlumbers::Generators::TokensDirective.directive
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
