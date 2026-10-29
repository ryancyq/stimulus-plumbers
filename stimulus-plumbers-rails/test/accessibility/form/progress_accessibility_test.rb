# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class ProgressFieldAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/form/progress"
  end

  def test_every_section_passes_wcag
    assert_sections_accessible
  end

  def test_progressbar_is_named_by_its_visible_label
    labelledby = first("#progress-field-percent [role='progressbar']")[:"aria-labelledby"]

    assert_selector "#progress-field-percent span##{labelledby}", text: "Upload progress"
  end

  def test_no_label_element_points_at_a_non_labelable_element
    assert_no_selector "[id^='progress-field'] label"
  end
end
