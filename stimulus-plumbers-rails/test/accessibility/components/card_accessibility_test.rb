# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class CardAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/layout/card"
  end

  def test_default_cards_pass_wcag
    assert_accessible context: "#card-default"
  end

  def test_cards_with_cta_pass_wcag
    assert_accessible context: "#card-cta"
  end

  def test_variant_cards_pass_wcag
    assert_accessible context: "#card-variants"
  end
end
