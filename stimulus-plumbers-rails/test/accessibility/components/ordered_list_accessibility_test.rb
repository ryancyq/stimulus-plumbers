# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class OrderedListAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/ordered_list"
  end

  def test_default_ordered_list_passes_wcag
    assert_accessible context: "#ordered-list-default"
  end

  def test_ordered_list_with_links_in_editing_state_passes_wcag
    assert_accessible context: "#ordered-list-with-links"
  end

  def test_ordered_list_custom_handle_icon_passes_wcag
    assert_accessible context: "#ordered-list-custom-handle-icon"
  end
end
