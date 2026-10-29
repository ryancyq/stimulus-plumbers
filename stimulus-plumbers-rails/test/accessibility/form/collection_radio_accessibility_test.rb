# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class CollectionRadioAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/form/collection_radio"
  end

  def test_every_section_passes_wcag
    assert_sections_accessible
  end
end
