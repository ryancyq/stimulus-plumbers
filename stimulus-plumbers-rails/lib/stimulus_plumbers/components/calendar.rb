# frozen_string_literal: true

module StimulusPlumbers
  module Components
    # The `calendar` root: settings and availability values, the status region, and the navigation's body.
    class Calendar < Plumber::Base
      include Plumber::Options::Choice

      STIMULUS_CONTROLLER = "calendar"
      VIEWS               = %i[month year decade].freeze
      NAVIGATIONS         = %i[stimulus turbo].freeze

      # Options: `navigation` (`:stimulus` or `:turbo`), `url` with `:turbo`, Configuration::OPTIONS, and
      # Availability::OPTIONS; the rest go to the root.
      def render(id:, view: nil, navigation: :stimulus, **kwargs)
        body          = navigation_for(navigation, kwargs)
        configuration = Configuration.extract!(id, view, kwargs)

        template.content_tag(:div, **root_attrs(configuration, kwargs, body.root_data(configuration))) do
          template.safe_join([status, body.render(configuration)])
        end
      end

      private

      def navigation_for(navigation, kwargs)
        case validate_choice!(navigation, NAVIGATIONS, :navigation)
        when :stimulus then Stimulus.new(template)
        when :turbo    then Turbo.new(template, kwargs.delete(:url))
        end
      end

      def root_attrs(configuration, html_options, data)
        merge_html_options(
          theme.resolve(:calendar),
          html_options,
          {
            id:   configuration.id,
            data: {
              controller: STIMULUS_CONTROLLER,
              action:     "click->#{STIMULUS_CONTROLLER}#onClick",
              **settings_values(configuration),
              **availability_values(configuration.availability)
            }
          },
          { data: data }
        )
      end

      def settings_values(configuration)
        {
          "calendar-selected-value"   => configuration.selected&.iso8601,
          "calendar-selectable-value" => configuration.selectable.to_s,
          "calendar-labels-value"     => labels.to_json
        }.compact
      end

      def labels
        scope = "stimulus_plumbers.calendar"
        {
          previousMonth:  I18n.t("#{scope}.previous_month"),
          nextMonth:      I18n.t("#{scope}.next_month"),
          previousYear:   I18n.t("#{scope}.previous_year"),
          nextYear:       I18n.t("#{scope}.next_year"),
          previousDecade: I18n.t("#{scope}.previous_decade"),
          nextDecade:     I18n.t("#{scope}.next_decade"),
          chooseMonth:    I18n.t("#{scope}.zoom_out.year"),
          chooseYear:     I18n.t("#{scope}.zoom_out.decade"),
          error:          I18n.t("#{scope}.error")
        }
      end

      def availability_values(availability)
        {
          "calendar-min-value"               => availability.min&.iso8601,
          "calendar-max-value"               => availability.max&.iso8601,
          "calendar-disabled-dates-value"    => json(availability.disabled_dates.map(&:iso8601)),
          "calendar-disabled-weekdays-value" => json(availability.disabled_weekdays),
          "calendar-disabled-months-value"   => json(availability.disabled_months),
          "calendar-disabled-years-value"    => json(availability.disabled_years)
        }.compact
      end

      def json(values)
        values.to_json if values.any?
      end

      # Outside the frame.
      def status
        template.content_tag(
          :div,
          nil,
          **merge_html_options(
            theme.resolve(:calendar_status),
            { role: "status", data: { "#{STIMULUS_CONTROLLER}-target" => "status" } }
          )
        )
      end
    end
  end
end
