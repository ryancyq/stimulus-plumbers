# frozen_string_literal: true

require "test_helper"

class TimesTest < ActiveSupport::TestCase
  TimeFixtures.fixture("availability")["parse"].each_with_index do |rule, index|
    define_method("test_parse_key_#{index}_#{rule["value"].parameterize(separator: "_")}") do
      key = StimulusPlumbers::Times.parse_key(rule["value"])
      if rule["expect"]
        assert_equal rule["expect"], key
      else
        assert_nil key
      end
    end
  end

  def test_parse_key_reads_a_time_by_its_clock_without_seconds
    Time.use_zone("Asia/Singapore") do
      assert_equal "09:30", StimulusPlumbers::Times.parse_key(Time.utc(2000, 1, 1, 9, 30, 45))
      assert_equal "09:30", StimulusPlumbers::Times.parse_key(Time.zone.local(2026, 11, 3, 9, 30))
      assert_equal "09:30", StimulusPlumbers::Times.parse_key(DateTime.new(2026, 11, 3, 9, 30))
    end
  end

  def test_parse_key_returns_nil_for_anything_else
    [Date.new(2026, 11, 3), nil, 930].each do |value|
      assert_nil StimulusPlumbers::Times.parse_key(value), value.inspect
    end
  end
end
