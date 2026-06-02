# frozen_string_literal: true

require "test_helper"

class CalendarTurboYearsOfDecadeTest < ActionView::TestCase
  def renderer(date: Date.new(2026, 6, 1), today: Date.new(2026, 6, 1), selected_date: nil)
    StimulusPlumbers::Components::Calendar::Turbo::YearsOfDecade
      .new(self, date: date, today: today, selected_date: selected_date)
  end

  def doc(**kwargs)
    parse_html(renderer(**kwargs).render)
  end

  def test_renders_rowgroup_role
    assert_css doc, "[role='rowgroup']"
  end

  def test_renders_12_gridcells
    assert_equal 12, doc.css("[role='gridcell']").length
  end

  def test_renders_3_rows
    assert_equal 3, doc.css("[role='row']").length
  end

  def test_each_row_has_4_cells
    doc.css("[role='row']").each do |row|
      assert_equal 4, row.css("[role='gridcell']").length
    end
  end

  def test_all_cells_are_buttons
    assert_equal 12, doc.css("button[role='gridcell']").length
  end

  def test_decade_spans_correct_years
    result = doc(date: Date.new(2026, 1, 1))
    years = result.css("[data-year]").map { |el| el["data-year"].to_i }

    assert_equal (2019..2030).to_a, years.sort
  end

  def test_buffer_years_have_aria_disabled
    result = doc(date: Date.new(2026, 1, 1))

    disabled = result.css("[aria-disabled='true']")
    disabled_years = disabled.map { |el| el["data-year"].to_i }.sort

    assert_equal [2019, 2030], disabled_years
  end

  def test_decade_years_do_not_have_aria_disabled
    result = doc(date: Date.new(2026, 1, 1))

    non_disabled = result.css("[role='gridcell']:not([aria-disabled='true'])")

    assert_equal 10, non_disabled.length
  end

  def test_current_year_has_aria_current
    result = doc(date: Date.new(2026, 1, 1), today: Date.new(2026, 6, 1))

    assert_equal 1, result.css("[aria-current='year']").length
    assert_equal "2026", result.at_css("[aria-current='year']")["data-year"]
  end

  def test_selected_year_has_aria_selected_true
    result = doc(date: Date.new(2026, 1, 1), selected_date: Date.new(2023, 4, 10))

    assert_equal 1, result.css("[aria-selected='true']").length
    assert_equal "2023", result.at_css("[aria-selected='true']")["data-year"]
  end

  def test_unselected_years_have_aria_selected_false
    result = doc(date: Date.new(2026, 1, 1), selected_date: Date.new(2023, 4, 10))

    assert_equal 11, result.css("[aria-selected='false']").length
  end

  def test_without_selected_date_all_have_aria_selected_false
    result = doc(selected_date: nil)

    assert_equal 12, result.css("[aria-selected='false']").length
    assert_equal 0,  result.css("[aria-selected='true']").length
  end

  def test_focused_cell_has_tabindex_zero
    result = doc(date: Date.new(2026, 1, 1), today: Date.new(2026, 6, 1))

    assert_equal 1, result.css("[tabindex='0']").length
    assert_equal "2026", result.at_css("[tabindex='0']")["data-year"]
  end
end
