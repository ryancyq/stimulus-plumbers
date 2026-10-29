# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class PasswordAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/form/password"
  end

  def test_every_section_passes_wcag
    assert_sections_accessible
  end

  def test_revealable_revealed_passes_wcag
    find("#password-revealable button[aria-label='Show password']").click

    assert_selector "#password-revealable input[type='text']"
    assert_accessible context: "#password-revealable"
  end

  def test_strength_populated_passes_wcag
    find("#password-strength input[type='password']").fill_in with: "Abcdef123456!"

    assert_selector "#password-strength li[data-rule][data-satisfied='true']", count: 4
    assert_accessible context: "#password-strength"
  end

  # WCAG 1.4.1 Use of Color is not machine-checkable, and rule state is the one place
  # in this component where color could silently become the sole signal.
  def test_satisfied_rule_is_not_indicated_by_color_alone
    find("#password-strength input[type='password']").fill_in with: "Abcdef123456!"

    assert_selector "#password-strength li[data-rule='digit'][data-satisfied='true'] " \
                    "[data-password-strength-target='checkIcon']:not([hidden])"
    assert_selector "#password-strength li[data-rule='digit'] " \
                    "[data-password-strength-target='closeIcon'][hidden]",
                    visible: :all
  end
end
