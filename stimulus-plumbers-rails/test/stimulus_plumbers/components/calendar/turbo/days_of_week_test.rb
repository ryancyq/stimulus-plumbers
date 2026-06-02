# frozen_string_literal: true

require "test_helper"

class CalendarTurboDaysOfWeekTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Calendar::Turbo::DaysOfWeek.new(self)
  end

  def test_renders_seven_column_headers
    assert_equal 7, renderer.render.scan('role="columnheader"').length
  end

  def test_column_headers_are_in_a_row
    assert_includes renderer.render, 'role="row"'
  end

  def test_merges_custom_class
    assert_includes renderer.render(class: "my-week-header"), "my-week-header"
  end
end
