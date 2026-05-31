# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class AvatarAccessibilityTest < ApplicationAccessibilityTestCase
  def test_passes_wcag
    visit "/components/avatar"

    assert_accessible context: "#avatar"
  end
end
