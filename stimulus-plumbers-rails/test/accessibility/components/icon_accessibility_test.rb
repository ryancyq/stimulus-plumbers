# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class IconAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/display/icon"
  end

  def test_decorative_icons_pass_wcag
    assert_accessible context: "#icon-decorative"
  end

  def test_functional_icons_pass_wcag
    assert_accessible context: "#icon-functional"
  end

  def test_icons_in_buttons_pass_wcag
    assert_accessible context: "#icon-in-button"
  end
end
