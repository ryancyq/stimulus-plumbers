# frozen_string_literal: true

require "test_helper"

class TimeAvailabilityValidatorTest < ActiveSupport::TestCase
  class Shift
    include ActiveModel::Validations

    class << self
      def model_name
        ActiveModel::Name.new(self, nil, "Shift")
      end
    end

    attr_accessor :at, :opening

    def initialize(at, opening: nil)
      @at      = at
      @opening = opening
    end
  end

  OPENING = { min: "09:00", max: "17:00", step: 15 }.freeze

  def shift_class(**options)
    Class.new(Shift) { validates :at, time_availability: options }
  end

  def errors_for(value, klass: shift_class(**OPENING), **attributes)
    shift = klass.new(value, **attributes)
    shift.validate
    shift.errors[:at]
  end

  def test_an_available_time_passes
    assert_empty errors_for("09:15")
    assert_empty errors_for(Time.utc(2000, 1, 1, 17, 0))
  end

  def test_a_time_before_min_is_too_early
    assert_equal ["must be 9:00 AM or later"], errors_for("08:45")
  end

  def test_a_time_after_max_is_too_late
    assert_equal ["must be 5:00 PM or earlier"], errors_for("17:15")
  end

  def test_a_min_after_max_wraps_past_midnight
    klass = shift_class(min: "22:00", max: "02:00", step: 15)

    assert_empty errors_for("23:00", klass: klass)
    assert_empty errors_for("01:30", klass: klass)
    assert_equal ["must be from 10:00 PM to 2:00 AM"], errors_for("03:00", klass: klass)
    assert_equal ["must be in steps of 15 minutes"], errors_for("23:10", klass: klass)
  end

  def test_a_time_off_the_step_is_a_step_mismatch
    assert_equal ["must be in steps of 15 minutes"], errors_for("09:20")
  end

  def test_seconds_are_ignored
    assert_empty errors_for(Time.utc(2000, 1, 1, 9, 15, 30))
  end

  def test_a_blank_value_passes
    assert_empty errors_for(nil)
    assert_empty errors_for("")
  end

  def test_a_value_that_is_not_a_time_key_is_invalid
    assert_equal ["is invalid"], errors_for("9:15")
  end

  def test_a_value_that_failed_to_cast_is_invalid
    klass = Class.new(shift_class(**OPENING)) { define_method(:at_before_type_cast) { "25:00" } }

    assert_equal ["is invalid"], errors_for(nil, klass: klass)
  end

  def test_a_time_is_read_by_its_clock
    Time.use_zone("Asia/Singapore") do
      assert_empty errors_for(Time.utc(2000, 1, 1, 9, 30))
      assert_empty errors_for(Time.zone.local(2026, 11, 3, 9, 30))
      assert_equal ["must be 9:00 AM or later"], errors_for(Time.zone.local(2026, 11, 3, 8, 30))
    end
  end

  def test_a_symbol_option_resolves_against_the_record
    klass = shift_class(min: :opening)

    assert_equal ["must be 10:00 AM or later"], errors_for("09:00", klass: klass, opening: "10:00")
  end

  def test_unusable_static_options_raise_when_declared
    assert_raises(ArgumentError) { shift_class(step: 45) }
    assert_raises(ArgumentError) { shift_class(min: "09:05", max: "09:10", step: 15) }
  end
end
