# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class ListAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/list"
  end

  def test_default_list_passes_wcag
    assert_accessible context: "#list-default"
  end

  def test_sections_pass_wcag
    assert_accessible context: "#list-sections"
  end

  def test_active_item_passes_wcag
    assert_accessible context: "#list-active"
  end

  def test_nested_sections_pass_wcag
    assert_accessible context: "#list-nested"
  end

  def test_hierarchical_sections_pass_wcag
    assert_accessible context: "#list-hierarchical"
  end
end
