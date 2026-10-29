# frozen_string_literal: true

require "test_helper"

class CalendarHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::CalendarHelper

  def test_renders_a_calendar
    assert_css parse_html(sp_calendar(id: "cal")), "div#cal[data-controller~='calendar']"
  end
end
