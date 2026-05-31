# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class CardAccessibilityTest < ApplicationAccessibilityTestCase
  def test_passes_wcag
    visit "/components/card"

    assert_accessible context: "#card"
  end
end
