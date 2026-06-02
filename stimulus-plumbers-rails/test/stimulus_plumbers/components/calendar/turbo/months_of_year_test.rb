# frozen_string_literal: true

require "test_helper"

class CalendarTurboMonthsOfYearTest < ActionView::TestCase
  def renderer(date: Date.new(2026, 6, 1), today: Date.new(2026, 6, 1), selected_date: nil, format: :short)
    StimulusPlumbers::Components::Calendar::Turbo::MonthsOfYear
      .new(self, date: date, today: today, selected_date: selected_date, format: format)
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

  def test_current_month_has_aria_current
    result = doc(date: Date.new(2026, 6, 1), today: Date.new(2026, 6, 1))

    assert_css result, "[aria-current='month']"
    assert_equal 1, result.css("[aria-current='month']").length
  end

  def test_other_months_do_not_have_aria_current
    result = doc(date: Date.new(2026, 6, 1), today: Date.new(2026, 6, 1))
    non_current = result.css("[role='gridcell']:not([aria-current='month'])")

    assert_equal 11, non_current.length
  end

  def test_selected_month_has_aria_selected_true
    result = doc(date: Date.new(2026, 6, 1), selected_date: Date.new(2026, 3, 15))

    assert_equal 1, result.css("[aria-selected='true']").length
    assert_equal "3", result.at_css("[aria-selected='true']")["data-month"]
  end

  def test_unselected_months_have_aria_selected_false
    result = doc(date: Date.new(2026, 6, 1), selected_date: Date.new(2026, 3, 15))

    assert_equal 11, result.css("[aria-selected='false']").length
  end

  def test_without_selected_date_all_have_aria_selected_false
    result = doc(selected_date: nil)

    assert_equal 12, result.css("[aria-selected='false']").length
    assert_equal 0,  result.css("[aria-selected='true']").length
  end

  def test_cells_have_data_month_attribute
    result = doc
    months = result.css("[data-month]").map { |el| el["data-month"].to_i }

    assert_equal (1..12).to_a, months.sort
  end

  def test_focused_cell_has_tabindex_zero
    result = doc(date: Date.new(2026, 6, 1), today: Date.new(2026, 6, 1))

    assert_equal 1, result.css("[tabindex='0']").length
    assert_equal "6", result.at_css("[tabindex='0']")["data-month"]
  end

  def test_short_format_renders_abbreviated_names
    result = doc(format: :short)
    buttons = result.css("button[role='gridcell']")

    assert_equal "Jan", buttons[0].text
    assert_equal "Jun", buttons[5].text
    assert_equal "Dec", buttons[11].text
  end

  def test_long_format_renders_full_names
    result = doc(format: :long)
    buttons = result.css("button[role='gridcell']")

    assert_equal "January", buttons[0].text
    assert_equal "June", buttons[5].text
    assert_equal "December", buttons[11].text
  end

  def test_narrow_format_renders_single_character
    result = doc(format: :narrow)
    buttons = result.css("button[role='gridcell']")

    assert_equal "J", buttons[0].text
    assert_equal "J", buttons[5].text
    assert_equal "D", buttons[11].text
  end

  def test_narrow_format_has_aria_label_with_abbreviated_name
    result = doc(format: :narrow)
    buttons = result.css("button[role='gridcell']")

    assert_equal "Jan", buttons[0]["aria-label"]
    assert_equal "Jun", buttons[5]["aria-label"]
    assert_equal "Dec", buttons[11]["aria-label"]
  end

  def test_short_format_has_no_aria_label
    result = doc(format: :short)

    result.css("button[role='gridcell']").each do |btn|
      assert_nil btn["aria-label"]
    end
  end

  def test_long_format_has_no_aria_label
    result = doc(format: :long)

    result.css("button[role='gridcell']").each do |btn|
      assert_nil btn["aria-label"]
    end
  end
end
