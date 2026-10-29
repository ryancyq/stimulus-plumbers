# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class ProgressFieldAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/form/progress"
  end

  def test_percent_readout_passes_wcag
    assert_accessible context: "#progress-field-percent"
  end

  def test_percent_readout_with_hint_passes_wcag
    assert_accessible context: "#progress-field-hint"
  end

  def test_segmented_passes_wcag
    assert_accessible context: "#progress-field-segmented"
  end

  def test_progressbar_is_named_by_its_visible_label
    labelledby = first("#progress-field-percent [role='progressbar']")[:"aria-labelledby"]

    assert_selector "#progress-field-percent span##{labelledby}", text: "Upload progress"
  end

  def test_no_label_element_points_at_a_non_labelable_element
    assert_no_selector "[id^='progress-field'] label"
  end
end
