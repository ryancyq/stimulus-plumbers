# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class CollectionCheckboxAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/form/collection_checkbox"
  end

  def test_every_section_passes_wcag
    assert_sections_accessible
  end
end
