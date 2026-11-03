# frozen_string_literal: true

require "test_helper"

class DatetimesTest < ActiveSupport::TestCase
  DatetimeFixtures.fixture("availability")["parse"].each_with_index do |rule, index|
    define_method("test_parse_key_#{index}_#{rule["value"].parameterize(separator: "_")}") do
      key = StimulusPlumbers::Datetimes.parse_key(rule["value"])
      if rule["expect"]
        assert_equal rule["expect"], key
      else
        assert_nil key
      end
    end
  end

  def test_parse_key_reads_a_time_in_the_time_zone_without_seconds
    Time.use_zone("Asia/Singapore") do
      assert_equal "2026-11-04T06:30", StimulusPlumbers::Datetimes.parse_key(Time.utc(2026, 11, 3, 22, 30, 45))
      assert_equal "2026-11-03T22:30", StimulusPlumbers::Datetimes.parse_key(Time.zone.local(2026, 11, 3, 22, 30))
    end
  end

  def test_parse_key_returns_nil_for_anything_else
    [Date.new(2026, 11, 3), "22:30", nil].each do |value|
      assert_nil StimulusPlumbers::Datetimes.parse_key(value), value.inspect
    end
  end
end
