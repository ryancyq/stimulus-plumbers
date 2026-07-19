# frozen_string_literal: true

require "test_helper"
require "stimulus_plumbers/generators/tokens_directive"
require "stimulus_plumbers/tailwind/generators/animations_directive"
require "stimulus_plumbers/tailwind/generators/sources_directive"

class TailwindSandboxCssTest < Minitest::Test
  SANDBOX_CSS = File.expand_path("../../sandbox/app/assets/stylesheets/application.css", __dir__)
  SANDBOX_CSS_DIR = File.dirname(SANDBOX_CSS)
  SANDBOX_ROOT = File.expand_path("../../sandbox", __dir__)
  SANDBOX_SOURCES_CSS = File.join(
    SANDBOX_ROOT,
    StimulusPlumbers::Tailwind::Generators::SourcesDirective::SOURCES_CSS_PATH
  )

  # Guards against hand-edited drift: the sandbox entry's generator-owned imports
  # must always be exactly what the install generator would produce for this
  # exact path, so it stays a faithful preview of a real consumer's CSS. Calls
  # the same directive builders the generator itself calls — never reimplements
  # their path arithmetic — so this can't silently drift from real behavior.
  # Purely read-only — no generator invocation, no writes, real or otherwise.
  def test_sandbox_tailwind_css_has_the_generator_computed_tokens_import
    content = File.read(SANDBOX_CSS)
    directive = StimulusPlumbers::Generators::TokensDirective.directive(
      from: SANDBOX_CSS_DIR, destination_root: SANDBOX_ROOT
    )

    assert_equal 1, content.scan(directive).length, <<~MSG
      test/sandbox/app/assets/stylesheets/application.css's @import for tokens.css doesn't match what the install
      generator computes for this path. Regenerate it with:
        STIMULUS_PLUMBERS_CSS_ENTRY=test/sandbox/app/assets/stylesheets/application.css bin/rails generate stimulus_plumbers:tailwind:install
      then commit the diff.
    MSG
  end

  def test_sandbox_tailwind_css_has_the_generator_computed_animations_import
    content = File.read(SANDBOX_CSS)
    directive = StimulusPlumbers::Tailwind::Generators::AnimationsDirective.directive(
      from: SANDBOX_CSS_DIR, destination_root: SANDBOX_ROOT
    )

    assert_equal 1, content.scan(directive).length, <<~MSG
      test/sandbox/app/assets/stylesheets/application.css's @import for animations.css doesn't match what the install
      generator computes for this path. Regenerate it with:
        STIMULUS_PLUMBERS_CSS_ENTRY=test/sandbox/app/assets/stylesheets/application.css bin/rails generate stimulus_plumbers:tailwind:install
      then commit the diff.
    MSG
  end

  def test_sandbox_tailwind_css_has_the_generator_computed_sources_import_and_app_views_source
    content = File.read(SANDBOX_CSS)
    directive = StimulusPlumbers::Tailwind::Generators::SourcesDirective.import_directive(
      from: SANDBOX_CSS_DIR, destination_root: SANDBOX_ROOT
    )

    assert_equal 1, content.scan(directive).length, <<~MSG
      test/sandbox/app/assets/stylesheets/application.css's @import for sources.css doesn't match what the install
      generator computes for this path. Regenerate it with:
        STIMULUS_PLUMBERS_CSS_ENTRY=test/sandbox/app/assets/stylesheets/application.css bin/rails generate stimulus_plumbers:tailwind:install
      then commit the diff.
    MSG
    assert_includes content, %(@source "../../views/**/*.erb";)
  end

  def test_sandbox_sources_css_has_the_generator_computed_contents
    assert_equal(
      StimulusPlumbers::Tailwind::Generators::SourcesDirective.file_contents(from: File.dirname(SANDBOX_SOURCES_CSS)),
      File.read(SANDBOX_SOURCES_CSS),
      <<~MSG
        test/sandbox/app/assets/builds/stimulus_plumbers/tailwind.css doesn't match what the install
        generator computes for this path. Regenerate it with:
          STIMULUS_PLUMBERS_CSS_ENTRY=test/sandbox/app/assets/stylesheets/application.css bin/rails generate stimulus_plumbers:tailwind:install
        then commit the diff.
      MSG
    )
  end
end
