# frozen_string_literal: true

require "test_helper"

class CalendarMonthTurboRendererTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Calendar::Month::Turbo.new(self)
  end

  def test_exposes_template
    assert_equal self, renderer.template
  end

  def test_exposes_theme
    assert_equal StimulusPlumbers.config.theme, renderer.theme
  end

  # ── structure ────────────────────────────────────────────────────────
  def test_has_calendar_month_observer_controller
    assert_includes renderer.render(date: Date.new(2026, 4, 1)), 'data-controller="calendar-month-observer"'
  end

  def test_has_click_action_for_observer_controller
    assert_includes renderer.render(date: Date.new(2026, 4, 1)), "click-&gt;calendar-month-observer#select"
  end

  def test_has_grid_role
    assert_includes renderer.render(date: Date.new(2026, 4, 1)), 'role="grid"'
  end

  def test_merges_extra_data_attributes
    html = renderer.render(date: Date.new(2026, 4, 1), data: { foo: "bar" })

    assert_includes html, "data-foo"
    assert_includes html, "bar"
  end

  def test_merges_custom_class
    assert_includes renderer.render(date: Date.new(2026, 4, 1), class: "my-cal"), "my-cal"
  end

  # ── days of week ─────────────────────────────────────────────────────
  def test_renders_seven_column_headers
    assert_equal 7, renderer.render(date: Date.new(2026, 4, 1)).scan('role="columnheader"').length
  end

  def test_column_headers_are_in_a_row
    assert_includes renderer.render(date: Date.new(2026, 4, 1)), '<div role="row"'
  end

  # ── days of month ────────────────────────────────────────────────────
  def test_days_of_month_has_rowgroup_role
    assert_includes renderer.render(date: Date.new(2026, 4, 1)), 'role="rowgroup"'
  end

  def test_today_has_aria_current
    html = renderer.render(date: Date.new(2026, 4, 1), today: Date.new(2026, 4, 15))

    assert_includes html, 'aria-current="date"'
  end

  def test_only_one_cell_has_tabindex_zero
    html = renderer.render(date: Date.new(2026, 4, 1), today: Date.new(2026, 4, 15))

    assert_equal 1, html.scan('tabindex="0"').length
  end

  # ── gridcell counts ──────────────────────────────────────────────────
  def test_renders_28_gridcells_for_month_without_padding
    # Feb 2026: starts Sunday, 28 days, no padding
    html = renderer.render(date: Date.new(2026, 2, 1))

    assert_equal 28, html.scan('role="gridcell"').length
  end

  def test_renders_35_gridcells_including_hidden_padding
    # Apr 2026: 3 prev + 30 current + 2 next = 35
    html = renderer.render(date: Date.new(2026, 4, 1))

    assert_equal 35, html.scan('role="gridcell"').length
  end

  def test_renders_42_gridcells_for_6_week_month
    # Jul 2023: 6 prev + 31 current + 5 next = 42
    html = renderer.render(date: Date.new(2023, 7, 1), show_other_months: true)

    assert_equal 42, html.scan('role="gridcell"').length
  end

  # ── show_other_months ────────────────────────────────────────────────
  def test_padding_cells_are_aria_hidden_by_default
    # Apr 2026: 5 padding days (3 prev + 2 next)
    html = renderer.render(date: Date.new(2026, 4, 1))

    assert_not_includes html, 'aria-disabled="true"'
    assert_includes html, 'aria-hidden="true"'
  end

  def test_padding_cells_are_disabled_gridcells_when_show_other_months
    # Apr 2026: 5 padding days (3 prev + 2 next)
    html = renderer.render(date: Date.new(2026, 4, 1), show_other_months: true)

    assert_includes html, 'aria-disabled="true"'
    assert_not_includes html, 'aria-hidden="true"'
  end

  # ── selectable ───────────────────────────────────────────────────────
  def test_current_month_cells_are_spans_when_not_selectable
    # Feb 2026: no padding, all gridcells are current-month spans
    html = renderer.render(date: Date.new(2026, 2, 1))

    assert_not_includes html, "<button"
  end

  def test_current_month_cells_are_buttons_when_selectable
    # Feb 2026: no padding, all gridcells are buttons
    html = renderer.render(date: Date.new(2026, 2, 1), selectable: true)

    assert_includes html, "<button"
    assert_not_includes html, '<span role="gridcell"'
  end

  def test_selectable_cells_have_aria_selected
    html = renderer.render(date: Date.new(2026, 4, 1), selectable: true)

    assert_includes html, "aria-selected="
  end

  def test_non_selectable_cells_omit_aria_selected
    html = renderer.render(date: Date.new(2026, 4, 1))

    assert_not_includes html, "aria-selected="
  end

  def test_selected_date_has_aria_selected_true
    html = renderer.render(
      date:          Date.new(2026, 4, 1),
      today:         Date.new(2026, 4, 15),
      selectable:    true,
      selected_date: Date.new(2026, 4, 10)
    )

    assert_includes html, 'aria-selected="true"'
  end

  def test_non_selected_cells_have_aria_selected_false
    # Feb 2026: 28 days, no padding — 1 selected, 27 unselected
    html = renderer.render(
      date:          Date.new(2026, 2, 1),
      today:         Date.new(2026, 2, 1),
      selectable:    true,
      selected_date: Date.new(2026, 2, 10)
    )

    assert_equal 1,  html.scan('aria-selected="true"').length
    assert_equal 27, html.scan('aria-selected="false"').length
  end
end
