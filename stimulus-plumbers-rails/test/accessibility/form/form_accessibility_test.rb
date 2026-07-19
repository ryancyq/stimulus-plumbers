# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class FormAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/form/sign_up"
  end

  def test_passes_wcag
    assert_accessible context: "#sign-up"
  end

  def test_passes_wcag_with_password_revealed
    find("#sign-up button[aria-label='Show password']").click

    assert_accessible context: "#sign-up"
  end

  def test_passes_wcag_with_icon_only_submit
    assert_accessible context: "#sign-up-submit-icon-only"
  end
end
