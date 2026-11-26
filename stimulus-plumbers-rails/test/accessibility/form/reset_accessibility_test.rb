# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class FormResetAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/form/reset"
  end

  def test_comboboxes_pass_wcag
    assert_accessible context: "#reset-comboboxes"
  end
end
