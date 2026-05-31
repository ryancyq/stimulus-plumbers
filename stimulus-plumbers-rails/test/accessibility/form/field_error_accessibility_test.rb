# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class FieldErrorAccessibilityTest < ApplicationAccessibilityTestCase
  def test_passes_wcag
    visit "/form/field_error"

    assert_accessible context: "#field-error"
  end
end
