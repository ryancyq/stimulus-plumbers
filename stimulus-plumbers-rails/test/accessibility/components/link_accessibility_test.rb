# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class LinkAccessibilityTest < ApplicationAccessibilityTestCase
  def test_passes_wcag
    visit "/components/link"

    assert_accessible context: "#link"
  end
end
