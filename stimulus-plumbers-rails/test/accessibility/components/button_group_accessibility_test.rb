# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class ButtonGroupAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/controls/button_group"
  end

  def test_inline_passes_wcag
    assert_accessible context: "#button-group-inline"
  end

  def test_stacked_passes_wcag
    assert_accessible context: "#button-group-stacked"
  end

  def test_icons_passes_wcag
    assert_accessible context: "#button-group-icons"
  end
end
