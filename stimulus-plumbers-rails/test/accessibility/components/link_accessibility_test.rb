# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class LinkAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/controls/link"
  end

  def test_inline_passes_wcag
    assert_accessible context: "#link-inline"
  end

  def test_default_passes_wcag
    assert_accessible context: "#link-default"
  end

  def test_icons_passes_wcag
    assert_accessible context: "#link-icons"
  end

  def test_button_type_passes_wcag
    assert_accessible context: "#link-button"
  end

  def test_button_type_with_icons_passes_wcag
    assert_accessible context: "#link-button-icons"
  end

  def test_card_type_passes_wcag
    assert_accessible context: "#link-card"
  end
end
