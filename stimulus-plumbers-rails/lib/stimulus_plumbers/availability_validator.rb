# frozen_string_literal: true

module StimulusPlumbers
  # Validates a value against the availability its field offers. Options are AVAILABILITY::OPTIONS; a Proc, Symbol,
  # or callable resolves against the record. A blank value passes. Subclasses define AVAILABILITY, `parse`,
  # `localize`, and `mismatch_error`.
  class AvailabilityValidator < ActiveModel::EachValidator
    include ResolveValue

    def check_validity!
      self.class::AVAILABILITY.new(**availability_options.reject { |_name, value| dynamic?(value) })
    end

    def validate_each(record, attribute, value)
      return if before_type_cast(record, attribute, value).blank?

      key = parse(value)
      error, details = key ? first_error(key, availability(record)) : :invalid
      record.errors.add(attribute, error, **options.slice(:message, :strict), **details.to_h) if error
    end

    private

    # The first rule the key breaks, as [error, details], or nil.
    def first_error(key, availability)
      if availability.min && key < availability.min
        [:too_early, { count: localize(availability.min) }]
      elsif availability.max && key > availability.max
        [:too_late, { count: localize(availability.max) }]
      elsif availability.disabled?(key)
        mismatch_error(key, availability)
      end
    end

    def availability(record)
      self.class::AVAILABILITY.new(**availability_options.transform_values { |option| resolve_value(record, option) })
    end

    def availability_options
      options.slice(*self.class::AVAILABILITY::OPTIONS)
    end

    def dynamic?(value)
      value.is_a?(Symbol) || value.respond_to?(:call)
    end

    # A HH:MM key in `stimulus_plumbers.availability.time_format`.
    def localize_time(clock)
      hour, minute = clock.split(":").map(&:to_i)
      format = I18n.t("stimulus_plumbers.availability.time_format", default: "%H:%M")
      I18n.l(::Time.utc(2000, 1, 1, hour, minute), format: format)
    end

    # A value that failed to cast reads as nil; the value before casting tells it from a blank one.
    def before_type_cast(record, attribute, value)
      method = :"#{attribute}_before_type_cast"
      record.respond_to?(method) ? record.public_send(method) : value
    end
  end
end
