# frozen_string_literal: true

require_relative "../../application_accessibility_test_case"

class AvatarAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/display/avatar"
  end

  def test_initials_passes_wcag
    assert_accessible context: "#avatar-initials"
  end

  def test_image_passes_wcag
    assert_accessible context: "#avatar-image"
  end

  def test_fallback_passes_wcag
    assert_accessible context: "#avatar-fallback"
  end

  def test_sizes_passes_wcag
    assert_accessible context: "#avatar-sizes"
  end

  def test_explicit_variants_passes_wcag
    assert_accessible context: "#avatar-variants"
  end
end
