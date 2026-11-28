# frozen_string_literal: true

require "test_helper"

class DateAvailabilityValidatorTest < ActiveSupport::TestCase
  class Booking
    include ActiveModel::Validations

    class << self
      def model_name
        ActiveModel::Name.new(self, nil, "Booking")
      end
    end

    attr_accessor :on, :earliest

    def initialize(on, earliest: nil)
      @on       = on
      @earliest = earliest
    end
  end

  SEPTEMBER = { min: "2026-09-01", max: "2026-09-30", disabled_weekdays: [0, 6] }.freeze

  def booking_class(**options)
    Class.new(Booking) { validates :on, date_availability: options }
  end

  def errors_for(value, klass: booking_class(**SEPTEMBER), **attributes)
    booking = klass.new(value, **attributes)
    booking.validate
    booking.errors[:on]
  end

  def test_an_available_date_passes
    assert_empty errors_for(Date.new(2026, 9, 15))
    assert_empty errors_for("2026-09-15")
  end

  def test_a_date_before_min_is_too_early
    assert_equal ["must be 2026-09-01 or later"], errors_for(Date.new(2026, 8, 31))
  end

  def test_a_date_after_max_is_too_late
    assert_equal ["must be 2026-09-30 or earlier"], errors_for(Date.new(2026, 10, 1))
  end

  def test_an_unavailable_date_in_range_is_unavailable
    assert_equal ["is not available"], errors_for(Date.new(2026, 9, 13))
  end

  def test_a_blank_value_passes
    assert_empty errors_for(nil)
    assert_empty errors_for("")
  end

  def test_a_value_that_is_not_a_date_is_invalid
    assert_equal ["is invalid"], errors_for("2026-09-31")
  end

  def test_a_value_that_failed_to_cast_is_invalid
    klass = Class.new(booking_class(**SEPTEMBER)) { define_method(:on_before_type_cast) { "2026-13-01" } }

    assert_equal ["is invalid"], errors_for(nil, klass: klass)
  end

  def test_a_time_is_read_as_its_date_in_the_time_zone
    Time.use_zone("Asia/Singapore") do
      assert_equal ["must be 2026-09-01 or later"], errors_for(Time.utc(2026, 8, 31, 15, 59))
      assert_empty errors_for(Time.utc(2026, 8, 31, 16, 0))
    end
  end

  def test_message_replaces_the_default
    klass = booking_class(**SEPTEMBER, message: "is outside September")

    assert_equal ["is outside September"], errors_for(Date.new(2026, 8, 31), klass: klass)
  end

  def test_strict_raises
    klass = booking_class(**SEPTEMBER, strict: true)

    assert_raises(ActiveModel::StrictValidationFailed) { klass.new(Date.new(2026, 8, 31)).validate }
  end

  def test_if_skips_the_validation
    klass = booking_class(**SEPTEMBER, if: -> { false })

    assert_empty errors_for(Date.new(2026, 8, 31), klass: klass)
  end

  def test_proc_and_symbol_options_resolve_against_the_record
    klass = booking_class(min: :earliest, max: ->(booking) { booking.earliest + 1 })

    assert_equal ["must be 2026-09-01 or later"], errors_for(Date.new(2026, 8, 31), klass: klass, earliest: Date.new(2026, 9, 1))
    assert_equal ["must be 2026-09-02 or earlier"], errors_for(Date.new(2026, 9, 3), klass: klass, earliest: Date.new(2026, 9, 1))
  end

  def test_unusable_static_options_raise_when_declared
    assert_raises(ArgumentError) { booking_class(min: "September") }
    assert_raises(ArgumentError) { booking_class(min: "2026-09-30", max: "2026-09-01") }
  end
end
