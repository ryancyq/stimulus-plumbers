# frozen_string_literal: true

require "test_helper"

class CalendarHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::CalendarHelper

  def test_renders_a_calendar_the_controller_draws_by_default
    assert_equal "calendar", parse_html(sp_calendar(id: "cal")).at_css("div#cal")["data-controller"]
  end

  def test_renders_a_turbo_calendar
    assert_equal "calendar calendar-turbo",
                 parse_html(sp_calendar(id: "cal", navigation: :turbo)).at_css("div#cal")["data-controller"]
  end

  def test_rejects_an_unknown_navigation
    assert_raises(ArgumentError) { sp_calendar(id: "cal", navigation: :fetch) }
  end
end
