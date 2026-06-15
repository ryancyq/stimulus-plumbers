# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class ButtonAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/button"
  end

  def test_default_passes_wcag
    assert_accessible context: "#button-default"
  end

  def test_outline_passes_wcag
    assert_accessible context: "#button-outline"
  end

  def test_ghost_passes_wcag
    assert_accessible context: "#button-ghost"
  end

  def test_fab_passes_wcag
    assert_accessible context: "#button-fab"
  end

  def test_fab_outline_passes_wcag
    assert_accessible context: "#button-fab-outline"
  end

  def test_dashed_passes_wcag
    assert_accessible context: "#button-dashed"
  end

  def test_card_passes_wcag
    assert_accessible context: "#button-card"
  end

  def test_icons_passes_wcag
    assert_accessible context: "#button-icons"
  end

  def test_disabled_passes_wcag
    assert_accessible context: "#button-disabled"
  end
end
