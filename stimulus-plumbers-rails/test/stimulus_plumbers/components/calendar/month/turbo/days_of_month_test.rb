# frozen_string_literal: true

require "test_helper"

class CalendarMonthTurboDaysOfMonthTest < ActionView::TestCase
  def renderer(date: Date.new(2026, 4, 1), **opts)
    StimulusPlumbers::Components::Calendar::Month::Turbo::DaysOfMonth.new(self, date: date, **opts)
  end

  def test_renders_rowgroup
    assert_css parse_html(renderer.render), "[role='rowgroup']"
  end

  def test_today_has_aria_current_date
    html = renderer(today: Date.new(2026, 4, 15)).render

    assert_includes html, 'aria-current="date"'
  end

  def test_only_one_cell_has_tabindex_zero
    html = renderer(today: Date.new(2026, 4, 15)).render

    assert_equal 1, html.scan('tabindex="0"').length
  end

  def test_renders_28_gridcells_for_february_without_padding
    # Feb 2026: starts Sunday, 28 days, no padding
    html = renderer(date: Date.new(2026, 2, 1)).render

    assert_equal 28, html.scan('role="gridcell"').length
  end

  def test_renders_35_gridcells_for_april_with_padding
    # Apr 2026: 3 prev + 30 current + 2 next = 35
    html = renderer.render

    assert_equal 35, html.scan('role="gridcell"').length
  end

  def test_renders_42_gridcells_for_six_week_month
    # Jul 2023: 6 prev + 31 current + 5 next = 42
    html = renderer(date: Date.new(2023, 7, 1), show_other_months: true).render

    assert_equal 42, html.scan('role="gridcell"').length
  end

  def test_padding_cells_are_aria_hidden_by_default
    html = renderer.render

    assert_not_includes html, 'aria-disabled="true"'
    assert_includes html, 'aria-hidden="true"'
  end

  def test_padding_cells_are_disabled_when_show_other_months
    html = renderer(show_other_months: true).render

    assert_includes     html, 'aria-disabled="true"'
    assert_not_includes html, 'aria-hidden="true"'
  end

  def test_current_month_cells_are_spans_when_not_selectable
    html = renderer(date: Date.new(2026, 2, 1)).render

    assert_not_includes html, "<button"
  end

  def test_current_month_cells_are_buttons_when_selectable
    html = renderer(date: Date.new(2026, 2, 1), selectable: true).render

    assert_includes     html, "<button"
    assert_not_includes html, '<span role="gridcell"'
  end

  def test_selectable_cells_have_aria_selected
    assert_includes renderer(selectable: true).render, "aria-selected="
  end

  def test_non_selectable_cells_omit_aria_selected
    assert_not_includes renderer.render, "aria-selected="
  end

  def test_selected_date_has_aria_selected_true
    html = renderer(selectable: true, selected_date: Date.new(2026, 4, 10)).render

    assert_includes html, 'aria-selected="true"'
  end

  def test_non_selected_cells_have_aria_selected_false
    # Feb 2026: 28 days, no padding — 1 selected, 27 unselected
    html = renderer(
      date:          Date.new(2026, 2, 1),
      today:         Date.new(2026, 2, 1),
      selectable:    true,
      selected_date: Date.new(2026, 2, 10)
    ).render

    assert_equal 1,  html.scan('aria-selected="true"').length
    assert_equal 27, html.scan('aria-selected="false"').length
  end

  def test_merges_custom_class
    assert_includes renderer.render(class: "my-days"), "my-days"
  end
end
