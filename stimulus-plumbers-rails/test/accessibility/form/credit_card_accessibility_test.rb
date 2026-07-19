# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class CreditCardAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/form/credit_card"
  end

  def test_default_passes_wcag
    assert_accessible context: "#credit-card-default"
  end

  def test_separator_passes_wcag
    assert_accessible context: "#credit-card-separator"
  end
end
