# frozen_string_literal: true

require_relative "availability_validator"

# Top-level so `validates :attr, date_availability: {...}` resolves via Rails' symbol lookup.
class DateAvailabilityValidator < StimulusPlumbers::AvailabilityValidator
  AVAILABILITY = StimulusPlumbers::Dates::Availability

  private

  def parse(value)
    StimulusPlumbers::Dates.parse_key(value)
  end

  def localize(date)
    I18n.l(date)
  end

  def mismatch_error(_key, _availability)
    [:unavailable]
  end
end
