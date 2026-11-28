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

  def test_typing_a_card_number_groups_its_digits
    within "#credit-card-default" do
      find_field("Card number").send_keys "4242424242424242"

      assert_field "Card number", with: "4242 4242 4242 4242"
    end
  end

  def test_typing_a_card_number_groups_its_digits_with_the_separator
    within "#credit-card-separator" do
      find_field("Card number").send_keys "4242424242424242"

      assert_field "Card number", with: "4242-4242-4242-4242"
    end
  end
end
