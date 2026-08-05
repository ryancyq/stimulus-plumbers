# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class ProgressFieldAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/form/progress"
  end

  def test_progress_field_passes_wcag
    assert_accessible context: "#form-progress"
  end

  def test_progressbar_is_named_by_its_visible_label
    assert_selector "#form-progress span", text: "Upload progress"
    assert_selector "#form-progress [role='progressbar'][aria-labelledby]"
  end

  def test_no_label_element_points_at_a_non_labelable_element
    assert_no_selector "#form-progress label"
  end
end
