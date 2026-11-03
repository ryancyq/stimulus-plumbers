# frozen_string_literal: true

require_relative "availability_validator"

# Top-level so `validates :attr, datetime_availability: {...}` resolves via Rails' symbol lookup.
class DatetimeAvailabilityValidator < StimulusPlumbers::AvailabilityValidator
  AVAILABILITY = StimulusPlumbers::Datetimes::Availability

  private

  def parse(value)
    StimulusPlumbers::Datetimes.parse_key(value)
  end

  # `I18n.l` of the date, then the time in `stimulus_plumbers.availability.time_format`.
  def localize(key)
    "#{I18n.l(Date.iso8601(key[0, 10]))} #{localize_time(key[11, 5])}"
  end

  # Off `time.step` only when the date and the daily window allow the moment.
  def mismatch(key, availability)
    if availability.dates.disabled?(Date.iso8601(key[0, 10])) || availability.time.outside_window?(key[11, 5])
      [:unavailable]
    else
      [:step_mismatch, { count: availability.time.step }]
    end
  end
end
