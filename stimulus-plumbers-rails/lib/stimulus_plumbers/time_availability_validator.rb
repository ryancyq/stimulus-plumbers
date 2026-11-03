# frozen_string_literal: true

require_relative "availability_validator"

# Top-level so `validates :attr, time_availability: {...}` resolves via Rails' symbol lookup.
class TimeAvailabilityValidator < StimulusPlumbers::AvailabilityValidator
  AVAILABILITY = StimulusPlumbers::Times::Availability

  private

  # Outside a window that wraps past midnight names both ends.
  def first_error(key, availability)
    return super unless availability.wraps?

    if availability.outside_window?(key)
      [:outside_window, { min: localize(availability.min), max: localize(availability.max) }]
    elsif availability.disabled?(key)
      mismatch(key, availability)
    end
  end

  def parse(value)
    StimulusPlumbers::Times.parse_key(value)
  end

  def localize(key)
    localize_time(key)
  end

  def mismatch(_key, availability)
    [:step_mismatch, { count: availability.step }]
  end
end
