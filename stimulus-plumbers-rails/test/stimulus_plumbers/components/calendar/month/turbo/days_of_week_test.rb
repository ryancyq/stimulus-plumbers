# frozen_string_literal: true

require "test_helper"

class CalendarMonthTurboDaysOfWeekTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Calendar::Month::Turbo::DaysOfWeek.new(self)
  end

  def test_renders_seven_column_headers
    assert_equal 7, renderer.render.scan('role="columnheader"').length
  end

  def test_column_headers_are_in_a_row
    assert_includes renderer.render, 'role="row"'
  end

  def test_each_header_has_abbr_attribute
    doc = parse_html(renderer.render)

    doc.css("[role='columnheader']").each do |header|
      assert_predicate header["abbr"], :present?, "expected columnheader to have abbr attribute"
    end
  end

  def test_merges_custom_class
    assert_includes renderer.render(class: "my-week-header"), "my-week-header"
  end
end
