# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar < Plumber::Base
      include Plumber::Options::Choice

      STIMULUS_CONTROLLER   = "calendar"
      TURBO_CONTROLLER      = "calendar-turbo"
      VIEWS                 = %i[month year decade].freeze
      NAVIGATIONS           = %i[stimulus turbo].freeze
      AVAILABILITY_OPTIONS  = %i[min max disabled_dates disabled_weekdays disabled_months disabled_years].freeze
      CONFIGURATION_OPTIONS = %i[displayed selected today selectable show_other_months first_day_of_week url].freeze
      TURBO_ACTIONS         = [
        "click->#{STIMULUS_CONTROLLER}#onClick",
        "calendar:navigate->#{TURBO_CONTROLLER}#onNavigate",
        "turbo:before-fetch-response->#{TURBO_CONTROLLER}#onResponse",
        "turbo:frame-missing->#{TURBO_CONTROLLER}#onError",
        "turbo:fetch-request-error->#{TURBO_CONTROLLER}#onError",
        "#{TURBO_CONTROLLER}:failed->#{STIMULUS_CONTROLLER}#onFailed"
      ].join(" ").freeze

      class << self
        def frame_id_for(id)
          "#{id}_frame"
        end

        def display(date)
          I18n.l(date, format: :long)
        end
      end

      # Options: CONFIGURATION_OPTIONS and AVAILABILITY; the rest go to the root. An invalid `displayed`
      # or `view` falls back to its default.
      # `:stimulus` renders a template the controller draws; `:turbo` renders the period in a Turbo Frame.
      def render(id:, view: nil, navigation: :stimulus, **kwargs)
        validate_id!(id)
        view = view_for(view, build_configuration(id.to_s, kwargs))
        navigation = validate_choice!(navigation, NAVIGATIONS, :navigation)

        template.content_tag(:div, **root_attrs(id, kwargs, view, navigation)) do
          template.safe_join([status, period_frame(id, view, navigation)])
        end
      end

      private

      def build_configuration(id, kwargs)
        options = kwargs.extract!(*CONFIGURATION_OPTIONS)
        Configuration.new(
          id:                id,
          **configuration_dates(options),
          selectable:        options.fetch(:selectable, false),
          show_other_months: options.fetch(:show_other_months, false),
          first_day_of_week: first_day_of_week!(options[:first_day_of_week]),
          availability:      Availability.new(**kwargs.extract!(*AVAILABILITY_OPTIONS)),
          url:               options[:url],
          link:              period_link(id, options[:url])
        )
      end

      def configuration_dates(options)
        today = optional_date(options[:today], :today) || Date.current
        {
          today:     today,
          displayed: date_or_nil(options[:displayed]) || today,
          selected:  date_or_nil(options[:selected])
        }
      end

      def optional_date(value, name)
        Availability.date(value, name) unless value.nil?
      end

      def date_or_nil(value)
        optional_date(value, :date)
      rescue ArgumentError
        nil
      end

      def render_period(view)
        template.safe_join([Header.new(template).render(view), view.render])
      end

      def root_attrs(id, kwargs, view, navigation)
        turbo = navigation == :turbo
        data  = {
          controller: [STIMULUS_CONTROLLER, (TURBO_CONTROLLER if turbo)].compact.join(" "),
          action:     turbo ? TURBO_ACTIONS : "click->#{STIMULUS_CONTROLLER}#onClick",
          **settings_values(view.configuration, navigation),
          **(turbo ? { "calendar-url-value" => view.configuration.url } : period_values(view)).compact,
          **availability_values(view.configuration)
        }
        merge_html_options(theme.resolve(:calendar), kwargs, { id: id, data: data })
      end

      # Root values; the grid carries the shown period.
      def settings_values(configuration, navigation)
        {
          "calendar-selected-value"   => configuration.selected&.iso8601,
          "calendar-selectable-value" => configuration.selectable.to_s,
          "calendar-navigation-value" => navigation.to_s,
          "calendar-labels-value"     => labels.to_json
        }.compact
      end

      def period_values(view)
        configuration = view.configuration
        {
          "calendar-displayed-value"         => configuration.displayed.iso8601,
          "calendar-view-value"              => view.view_name.to_s,
          "calendar-today-value"             => configuration.today.iso8601,
          "calendar-locale-value"            => I18n.locale.to_s.tr("_", "-"),
          "calendar-first-day-of-week-value" => configuration.first_day_of_week.to_s,
          "calendar-show-other-months-value" => configuration.show_other_months.to_s
        }
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

      def availability_values(configuration)
        availability = configuration.availability
        {
          "calendar-min-value"               => key(availability.min),
          "calendar-max-value"               => key(availability.max),
          "calendar-disabled-dates-value"    => json(availability.disabled_dates.map(&:iso8601)),
          "calendar-disabled-weekdays-value" => json(availability.disabled_weekdays),
          "calendar-disabled-months-value"   => json(availability.disabled_months),
          "calendar-disabled-years-value"    => json(availability.disabled_years)
        }.compact
      end

      def key(date)
        date&.iso8601
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

      def period_frame(id, view, navigation)
        return Stimulus.new(template).render(view) unless navigation == :turbo

        template.content_tag(:"turbo-frame", id: self.class.frame_id_for(id)) { render_period(view) }
      end

      # `url`, or the current URL, plus <id>[displayed] and <id>[view].
      def period_link(id, url)
        path, query = url ? URI.parse(url).then { |uri| [uri.path, uri.query] } : current_path_and_query
        path  = path.sub(%r{\A/+}, "/") # a leading // would link to another host
        query = Rack::Utils.parse_nested_query(query)
        lambda do |displayed, view|
          "#{path}?#{query.deep_merge(id => { "displayed" => displayed.iso8601, "view" => view.to_s }).to_query}"
        end
      end

      # The request path and query string as sent; never parsed as a URI.
      def current_path_and_query
        [template.request.path, template.request.query_string]
      end

      def view_for(view, configuration)
        name = VIEWS.find { |candidate| candidate.to_s == view.to_s } || :month
        { month: DaysOfMonth, year: MonthsOfYear, decade: YearsOfDecade }.fetch(name).new(template, configuration)
      end

      def first_day_of_week!(value)
        value = DateAndTime::Calculations::DAYS_INTO_WEEK.fetch(Date.beginning_of_week) if value.nil?
        return value if value.is_a?(Integer) && (0..6).cover?(value)

        raise ArgumentError, "first_day_of_week must be 0–6"
      end

      def validate_id!(id)
        raise ArgumentError, "calendar id must be a nonblank stable id" if id.to_s.blank?
      end
    end
  end
end
