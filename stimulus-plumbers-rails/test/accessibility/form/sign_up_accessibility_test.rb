# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class SignUpAccessibilityTest < ApplicationAccessibilityTestCase
  def test_passes_wcag
    visit "/form/sign_up"

    assert_accessible context: "#sign-up"
  end

  def test_passes_wcag_with_password_revealed
    visit "/form/sign_up"
    find("button[aria-label='Show password']").click

    assert_accessible context: "#sign-up"
  end
end
