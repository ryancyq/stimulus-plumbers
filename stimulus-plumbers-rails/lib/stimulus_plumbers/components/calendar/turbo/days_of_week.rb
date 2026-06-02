# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar
      class Turbo
        class DaysOfWeek < Plumber::Base
          WEEKDAY_FORMATS = %i[narrow short long].freeze

          attr_reader :format

          def initialize(template, format: :short)
            super(template)
            @format = format
          end

          def render(...)
            render_days_of_week(...)
          end

          private

          def render_days_of_week(**kwargs)
            html_options = merge_html_options(
              theme.resolve(:calendar_days_of_week),
              kwargs
            )
            template.content_tag(:div, **html_options) { days_of_week }
          end

          def days_of_week
            week_options = merge_html_options(
              theme.resolve(:calendar_row),
              { role: "row" }
            )
            template.content_tag(:div, **week_options) do
              template.safe_join(
                day_names.map do |abbr, full|
                  options = { role: "columnheader" }
                  options[:aria] = { label: abbr } if format == :narrow
                  template.content_tag(:span, display_name(abbr, full), **options)
                end
              )
            end
          end

          def display_name(abbr, full)
            case format
            when :narrow then abbr[0, 1]
            when :long   then full
            else              abbr
            end
          end

          def day_names
            I18n.t("date.abbr_day_names").zip(I18n.t("date.day_names"))
          end
        end
      end
    end
  end
end
