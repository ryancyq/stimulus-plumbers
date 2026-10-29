# frozen_string_literal: true

require_relative "../../application_accessibility_test_case"

class AvatarAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/display/avatar"
  end

  def test_every_section_passes_wcag
    assert_sections_accessible
  end
end
