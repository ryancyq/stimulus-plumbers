# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class FieldsetAccessibilityTest < ApplicationAccessibilityTestCase
  def test_passes_wcag
    visit "/form/fieldset"

    assert_accessible
  end
end
