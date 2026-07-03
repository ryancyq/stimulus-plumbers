# frozen_string_literal: true

require "test_helper"
require "stimulus_plumbers/generators/tokens_directive"
require "stimulus_plumbers/tailwind/generators/sources_directive"

class TailwindSandboxCssTest < Minitest::Test
  SANDBOX_CSS = File.expand_path("../../sandbox/tailwind.css", __dir__)
  SANDBOX_CSS_DIR = File.dirname(SANDBOX_CSS)

  # Guards against hand-edited drift: the sandbox entry's @import/@source lines
  # must always be exactly what the install generator would produce for this
  # exact path, so it stays a faithful preview of a real consumer's CSS. Calls
  # the same directive builders the generator itself calls — never reimplements
  # their path arithmetic — so this can't silently drift from real behavior.
  # Purely read-only — no generator invocation, no writes, real or otherwise.
  def test_sandbox_tailwind_css_has_the_generator_computed_tokens_import
    content = File.read(SANDBOX_CSS)
    directive = StimulusPlumbers::Generators::TokensDirective.directive(from: SANDBOX_CSS_DIR)

    assert_equal 1, content.scan(directive).length, <<~MSG
      test/sandbox/tailwind.css's @import for tokens.css doesn't match what the install
      generator computes for this path. Regenerate it with:
        STIMULUS_PLUMBERS_CSS_ENTRY=test/sandbox/tailwind.css bin/rails generate stimulus_plumbers:tailwind:install
      then commit the diff.
    MSG
  end

  def test_sandbox_tailwind_css_has_the_generator_computed_source_directive
    content = File.read(SANDBOX_CSS)
    directive = StimulusPlumbers::Tailwind::Generators::SourcesDirective.directive(from: SANDBOX_CSS_DIR)

    assert_equal 1, content.scan(directive).length, <<~MSG
      test/sandbox/tailwind.css's @source directive doesn't match what the install
      generator computes for this path. Regenerate it with:
        STIMULUS_PLUMBERS_CSS_ENTRY=test/sandbox/tailwind.css bin/rails generate stimulus_plumbers:tailwind:install
      then commit the diff.
    MSG
  end
end
