# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class ButtonAccessibilityTest < ApplicationAccessibilityTestCase
  def test_passes_wcag
    visit "/components/button"

    assert_accessible context: "#button"
  end
end
