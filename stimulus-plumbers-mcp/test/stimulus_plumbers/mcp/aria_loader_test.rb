# frozen_string_literal: true

require_relative "../../test_helper"

class AriaLoaderTest < Minitest::Test
  def setup
    @aria = StimulusPlumbers::MCP::AriaLoader.call
  end

  def test_returns_markdown_reference
    assert_kind_of String, @aria
    assert_match(%r{# WCAG 2\.1 AA / ARIA Reference}, @aria)
  end

  def test_includes_component_specific_patterns
    assert_match(%r{Component-Specific Patterns}, @aria)
    assert_includes @aria, "modal_controller"
  end
end
