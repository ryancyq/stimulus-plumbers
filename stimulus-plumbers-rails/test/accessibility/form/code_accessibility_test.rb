# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class CodeAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/form/code"
  end

  def test_default_passes_wcag
    assert_accessible context: "#code-default"
  end
end
