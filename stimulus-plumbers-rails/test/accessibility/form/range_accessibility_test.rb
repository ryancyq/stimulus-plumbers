# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class RangeFieldAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/form/range"
  end

  def test_every_section_passes_wcag
    assert_sections_accessible
  end
end
