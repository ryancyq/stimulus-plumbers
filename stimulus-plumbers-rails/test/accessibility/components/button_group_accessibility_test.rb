# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class ButtonGroupAccessibilityTest < ApplicationAccessibilityTestCase
  def test_inline_passes_wcag
    visit "/components/button_group"

    assert_accessible context: "#button-group-inline"
  end

  def test_stacked_passes_wcag
    visit "/components/button_group"

    assert_accessible context: "#button-group-stacked"
  end
end
