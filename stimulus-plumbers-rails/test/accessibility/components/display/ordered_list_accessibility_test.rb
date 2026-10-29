# frozen_string_literal: true

require_relative "../../application_accessibility_test_case"

class OrderedListAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/display/ordered_list"
  end

  def test_every_section_passes_wcag
    assert_sections_accessible
  end
end
