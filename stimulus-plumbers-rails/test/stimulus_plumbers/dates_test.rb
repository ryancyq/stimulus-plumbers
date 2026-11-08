# frozen_string_literal: true

require "test_helper"

class DatesTest < ActiveSupport::TestCase
  def test_parse_key_reads_a_date_key
    assert_equal Date.new(2026, 9, 10), StimulusPlumbers::Dates.parse_key("2026-09-10")
  end

  def test_parse_key_returns_a_date_as_given
    date = Date.new(2026, 9, 10)

    assert_same date, StimulusPlumbers::Dates.parse_key(date)
  end

  def test_parse_key_reads_a_time_as_its_date_in_the_time_zone
    Time.use_zone("Asia/Singapore") do
      assert_equal Date.new(2026, 11, 4), StimulusPlumbers::Dates.parse_key(DateTime.new(2026, 11, 3, 23, 30))
      assert_equal Date.new(2026, 11, 4), StimulusPlumbers::Dates.parse_key(Time.utc(2026, 11, 3, 23, 30))
      assert_equal Date.new(2026, 11, 3), StimulusPlumbers::Dates.parse_key(Time.zone.local(2026, 11, 3, 23, 30))
    end
  end

  def test_parse_key_returns_nil_for_anything_else
    ["2026-9-10", "2026-02-30", "0000-01-01", "", nil, 20_260_910].each do |value|
      assert_nil StimulusPlumbers::Dates.parse_key(value), value.inspect
    end
  end
end
