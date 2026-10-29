# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class SignUpAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/form/sign_up"
  end

  def test_every_section_passes_wcag
    assert_sections_accessible
  end
end
