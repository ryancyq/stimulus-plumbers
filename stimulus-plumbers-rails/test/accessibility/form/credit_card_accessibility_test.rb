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

  def test_typing_a_full_card_number_fills_every_group
    within "#credit-card-default" do
      find("input[type='text']").send_keys "4242424242424242"

      assert_field type: "text", with: "4242 4242 4242 4242"
    end
  end
end
