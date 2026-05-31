# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class FloatingLabelAccessibilityTest < ApplicationAccessibilityTestCase
  def test_passes_wcag
    visit "/form/floating_label"

    assert_accessible context: "#floating-label"
  end
end
