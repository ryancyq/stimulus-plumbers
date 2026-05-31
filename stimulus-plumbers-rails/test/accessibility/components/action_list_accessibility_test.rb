# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class ActionListAccessibilityTest < ApplicationAccessibilityTestCase
  def test_passes_wcag
    visit "/components/action_list"

    assert_accessible context: "#action-list"
  end
end
