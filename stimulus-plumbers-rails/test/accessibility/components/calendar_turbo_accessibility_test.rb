# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class CalendarTurboAccessibilityTest < ApplicationAccessibilityTestCase
  # Each test covers a unique HTML output combination verified by axe.

  def test_passes_wcag_with_default_options
    # non-selectable spans, padding cells aria-hidden
    visit "/components/calendar_turbo"

    assert_accessible context: "#calendar"
  end

  def test_passes_wcag_when_selectable
    # button gridcells with aria-selected
    visit "/components/calendar_turbo?selectable=true"

    assert_accessible context: "#calendar"
  end

  def test_passes_wcag_with_other_months_visible
    # disabled other-month gridcells present alongside current-month spans
    visit "/components/calendar_turbo?show_other_months=true"

    assert_accessible context: "#calendar"
  end

  def test_passes_wcag_when_selectable_with_other_months_visible
    # button gridcells + disabled other-month gridcells
    visit "/components/calendar_turbo?selectable=true&show_other_months=true"

    assert_accessible context: "#calendar"
  end
end
