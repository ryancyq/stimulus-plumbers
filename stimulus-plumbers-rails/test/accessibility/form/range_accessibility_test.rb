# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class RangeFieldAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/form/range"
  end

  def test_every_section_passes_wcag
    assert_sections_accessible
  end

  # Unlike the progress field, a range is labelable — it takes a real <label for>.
  def test_range_is_named_by_a_real_label_element
    assert_selector "#range-field-default label[for='preferences_volume']", text: "Volume"
  end

  # The native input announces its own value; an exposed readout would double-announce it.
  def test_readout_is_hidden_from_assistive_technology
    assert_selector "#range-field-readout [data-progress-target='value'][aria-hidden='true']"
  end
end
