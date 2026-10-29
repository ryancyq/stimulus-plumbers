# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class ChoicesAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/form/choices"
  end

  def test_choices_form_passes_wcag
    assert_accessible context: "#choices-default"
  end
end
