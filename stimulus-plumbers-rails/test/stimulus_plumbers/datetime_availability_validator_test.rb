# frozen_string_literal: true

require "test_helper"

class DatetimeAvailabilityValidatorTest < ActiveSupport::TestCase
  class Booking
    include ActiveModel::Validations

    class << self
      def model_name
        ActiveModel::Name.new(self, nil, "Booking")
      end
    end

    attr_accessor :at, :opening

    def initialize(at, opening: nil)
      @at      = at
      @opening = opening
    end
  end

  SLOTS = {
    min: "2026-11-03T09:00", max: "2026-12-31T17:00", disabled_weekdays: [0],
    time: { min: "09:00", max: "22:00", step: 15 }
  }.freeze

  def booking_class(**options)
    Class.new(Booking) { validates :at, datetime_availability: options }
  end

  def errors_for(value, klass: booking_class(**SLOTS), **attributes)
    booking = klass.new(value, **attributes)
    booking.validate
    booking.errors[:at]
  end

  def test_an_available_moment_passes
    assert_empty errors_for("2026-11-03T21:15")
    assert_empty errors_for(Time.utc(2026, 12, 31, 17, 0))
  end

  def test_a_moment_before_min_is_too_early
    assert_equal ["must be 2026-11-03 9:00 AM or later"], errors_for("2026-11-03T08:45")
  end

  def test_a_moment_after_max_is_too_late
    assert_equal ["must be 2026-12-31 5:00 PM or earlier"], errors_for("2026-12-31T17:15")
  end

  def test_a_disabled_date_is_unavailable
    assert_equal ["is not available"], errors_for("2026-11-08T10:00")
  end

  def test_a_moment_outside_the_daily_window_is_unavailable
    assert_equal ["is not available"], errors_for("2026-11-04T08:00")
    assert_equal ["is not available"], errors_for("2026-11-04T22:05")
  end

  def test_a_wrapped_daily_window_judges_each_date_by_its_own_clock
    klass = booking_class(disabled_weekdays: [0], time: { min: "22:00", max: "02:00" })

    assert_empty errors_for("2026-11-07T01:00", klass: klass)
    assert_equal ["is not available"], errors_for("2026-11-07T03:00", klass: klass)
    assert_equal ["is not available"], errors_for("2026-11-08T01:00", klass: klass)
    assert_empty errors_for("2026-11-09T01:00", klass: klass)
  end

  def test_a_moment_off_the_step_is_a_step_mismatch
    assert_equal ["must be in steps of 15 minutes"], errors_for("2026-11-04T10:20")
  end

  def test_a_blank_value_passes
    assert_empty errors_for(nil)
    assert_empty errors_for("")
  end

  def test_a_value_that_is_not_a_date_time_key_is_invalid
    assert_equal ["is invalid"], errors_for("2026-11-04T10:00:00")
    assert_equal ["is invalid"], errors_for("2026-11-04")
  end

  def test_a_value_that_failed_to_cast_is_invalid
    klass = Class.new(booking_class(**SLOTS)) { define_method(:at_before_type_cast) { "2026-02-30T10:00" } }

    assert_equal ["is invalid"], errors_for(nil, klass: klass)
  end

  def test_a_time_is_read_in_the_time_zone
    Time.use_zone("Asia/Singapore") do
      assert_empty errors_for(Time.utc(2026, 11, 4, 2, 0))
      assert_equal ["is not available"], errors_for(Time.utc(2026, 11, 3, 23, 0))
    end
  end

  def test_a_symbol_option_resolves_against_the_record
    klass = booking_class(min: :opening)

    assert_equal ["must be 2026-11-04 10:00 AM or later"],
                 errors_for("2026-11-04T09:00", klass: klass, opening: "2026-11-04T10:00")
  end

  def test_a_resolved_option_that_leaves_no_time_raises
    klass = booking_class(min: :opening, max: "2026-11-04T11:00", time: { min: "12:00", max: "17:00" })

    assert_raises(ArgumentError) { errors_for("2026-11-04T12:00", klass: klass, opening: "2026-11-04T10:00") }
  end

  def test_unusable_static_options_raise_when_declared
    assert_raises(ArgumentError) { booking_class(min: "2026-12-31T17:00", max: "2026-11-03T09:00") }
    assert_raises(ArgumentError) { booking_class(time: { step: 45 }) }
  end
end
