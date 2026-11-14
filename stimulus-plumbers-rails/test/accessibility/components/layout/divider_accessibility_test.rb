# frozen_string_literal: true

require_relative "../../application_accessibility_test_case"

class DividerAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/layout/divider"
  end

  def test_default_passes_wcag
    assert_accessible context: "#divider-default"
  end

  def test_labeled_passes_wcag
    assert_accessible context: "#divider-labeled"
  end
end
