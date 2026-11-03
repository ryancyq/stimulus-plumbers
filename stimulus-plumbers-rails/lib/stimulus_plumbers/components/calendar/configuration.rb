# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar
      # The calendar's options. An invalid `displayed`, `selected`, or `view` falls back to its default.
      class Configuration
        OPTIONS = %i[displayed selected today selectable show_other_months first_day_of_week].freeze

        attr_reader :id,
                    :view,
                    :displayed,
                    :selected,
                    :today,
                    :availability,
                    :selectable,
                    :show_other_months,
                    :first_day_of_week

        class << self
          # Takes OPTIONS and Availability::OPTIONS out of `options`.
          def extract!(id, view, options)
            new(id, view, options.extract!(*OPTIONS), Availability.new(**options.extract!(*Availability::OPTIONS)))
          end
        end

        def initialize(id, view, options, availability)
          raise ArgumentError, "calendar id must be a nonblank stable id" if id.to_s.blank?

          @id                = id.to_s
          @view              = VIEWS.find { |candidate| candidate.to_s == view.to_s } || :month
          @availability      = availability
          @selectable        = options.fetch(:selectable, false)
          @show_other_months = options.fetch(:show_other_months, false)
          @first_day_of_week = parse_first_day_of_week!(options[:first_day_of_week])
          assign_dates(options)
        end

        def frame_id
          "#{id}_frame"
        end

        def heading_id
          "#{id}_heading"
        end

        private

        def assign_dates(options)
          @today     = optional_date(options[:today], :today) || Date.current
          @displayed = date_or_nil(options[:displayed]) || @today
          @selected  = date_or_nil(options[:selected])
        end

        def optional_date(value, name)
          Availability.date(value, name) unless value.nil?
        end

        def date_or_nil(value)
          optional_date(value, :date)
        rescue ArgumentError
          nil
        end

        def parse_first_day_of_week!(value)
          value = DateAndTime::Calculations::DAYS_INTO_WEEK.fetch(Date.beginning_of_week) if value.nil?
          return value if value.is_a?(Integer) && (0..6).cover?(value)

          raise ArgumentError, "first_day_of_week must be 0–6"
        end
      end
    end
  end
end
