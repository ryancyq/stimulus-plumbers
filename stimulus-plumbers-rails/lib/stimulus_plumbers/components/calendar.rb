# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar < Plumber::Base
      include Plumber::Options::Choice

      STIMULUS_CONTROLLER        = "calendar"
      TURBO_CONTROLLER           = "calendar-turbo"
      MONTH_STIMULUS_CONTROLLER  = "calendar-month"
      YEAR_STIMULUS_CONTROLLER   = "calendar-year"
      DECADE_STIMULUS_CONTROLLER = "calendar-decade"
      VIEWS                      = %i[month year decade].freeze
      NAVIGATIONS                = %i[stimulus turbo].freeze
      AVAILABILITY_OPTIONS       = %i[min max disabled_dates disabled_weekdays disabled_months disabled_years].freeze
      CONFIGURATION_OPTIONS      = %i[displayed selected today selectable show_other_months first_day_of_week url].freeze
      TURBO_ACTIONS              = [
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

      # Options: CONFIGURATION_OPTIONS and AVAILABILITY; the rest go to the container. An invalid `displayed`
      # or `view` falls back to its default.
      # `:stimulus` renders a template the controller draws; `:turbo` renders the period in a Turbo Frame.
      def render(id:, view: nil, navigation: :stimulus, **kwargs)
        validate_id!(id)
        view = view_for(view, build_configuration(id.to_s, kwargs))
        navigation = validate_choice!(navigation, NAVIGATIONS, :navigation)

        template.content_tag(:div, **container_attrs(id, kwargs, view, navigation)) do
          template.safe_join([status, period_frame(id, view, navigation)])
        end
      end

      def month(**kwargs)
        html_options = merge_html_options(
          theme.resolve(:calendar),
          kwargs,
          { data: { controller: MONTH_STIMULUS_CONTROLLER } },
          { data: stimulus_theme_options }
        )
        template.content_tag(:div, **html_options, role: "grid") do
          template.safe_join([days_of_week, days_of_month])
        end
      end

      def year(**kwargs)
        html_options = merge_html_options(
          {
            hidden: true,
            role:   "grid",
            aria:   { label: I18n.t("stimulus_plumbers.calendar.year_view") },
            data:   { controller: YEAR_STIMULUS_CONTROLLER }
          },
          kwargs
        )
        template.content_tag(:div, **html_options) do
          template.tag.div(data: { "#{YEAR_STIMULUS_CONTROLLER}-target": "grid" }, role: "rowgroup")
        end
      end

      def decade(**kwargs)
        html_options = merge_html_options(
          {
            hidden: true,
            role:   "grid",
            aria:   { label: I18n.t("stimulus_plumbers.calendar.decade_view") },
            data:   { controller: DECADE_STIMULUS_CONTROLLER }
          },
          kwargs
        )
        template.content_tag(:div, **html_options) do
          template.tag.div(data: { "#{DECADE_STIMULUS_CONTROLLER}-target": "grid" }, role: "rowgroup")
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
          first_day_of_week: parse_first_day_of_week!(options[:first_day_of_week]),
          availability:      Availability.new(**kwargs.extract!(*AVAILABILITY_OPTIONS)),
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

      def container_attrs(id, kwargs, view, navigation)
        turbo = navigation == :turbo
        data  = {
          controller: [STIMULUS_CONTROLLER, (TURBO_CONTROLLER if turbo)].compact.join(" "),
          action:     turbo ? TURBO_ACTIONS : "click->#{STIMULUS_CONTROLLER}#onClick",
          **settings_values(view.configuration, navigation),
          **(turbo ? {} : period_values(view).compact),
          **availability_values(view.configuration)
        }
        merge_html_options(theme.resolve(:calendar), kwargs, { id: id, data: data })
      end

      # Container values; the grid carries the shown period.
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

      # Builds a period URL from a date and a view; nil disables the control.
      def period_link(id, url)
        generator, init_args = url.nil? || url.is_a?(String) ? [PeriodUrl, [template, id, url]] : [url, []]
        lambda do |date, view|
          dispatcher = Plumber::Dispatcher.build(generator, date, view, method_name: :call, init_args: init_args)
          raise ArgumentError, "invalid url: #{url.inspect}" unless dispatcher

          dispatcher.call(template).presence
        end
      end

      def view_for(view, configuration)
        name = VIEWS.find { |candidate| candidate.to_s == view.to_s } || :month
        { month: DaysOfMonth, year: MonthsOfYear, decade: YearsOfDecade }.fetch(name).new(template, configuration)
      end

      def parse_first_day_of_week!(value)
        value = DateAndTime::Calculations::DAYS_INTO_WEEK.fetch(Date.beginning_of_week) if value.nil?
        return value if value.is_a?(Integer) && (0..6).cover?(value)

        raise ArgumentError, "first_day_of_week must be 0–6"
      end

      def validate_id!(id)
        raise ArgumentError, "calendar id must be a nonblank stable id" if id.to_s.blank?
      end

      def stimulus_theme_options
        {
          "#{MONTH_STIMULUS_CONTROLLER}-row-class":                theme.resolve(:calendar_row).fetch(:classes, ""),
          "#{MONTH_STIMULUS_CONTROLLER}-day-of-month-class":       theme.resolve(:calendar_day).fetch(:classes, ""),
          "#{MONTH_STIMULUS_CONTROLLER}-day-of-other-month-class": theme.resolve(:calendar_day, outside: true).fetch(:classes, "")
        }
      end

      def days_of_week
        template.tag.div(
          **merge_html_options(
            theme.resolve(:calendar_days_of_week),
            { data: { "#{MONTH_STIMULUS_CONTROLLER}-target": "daysOfWeek" } }
          )
        )
      end

      def days_of_month
        template.tag.div(
          **merge_html_options(
            theme.resolve(:calendar_days_of_month),
            {
              role: "rowgroup",
              data: { "#{MONTH_STIMULUS_CONTROLLER}-target": "daysOfMonth" }
            }
          )
        )
      end
    end
  end
end
