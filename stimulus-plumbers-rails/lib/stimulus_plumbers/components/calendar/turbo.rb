# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar
      # Turbo navigation: Rails renders each period inside a Turbo Frame that `calendar-turbo` reloads.
      class Turbo < Plumber::Base
        TURBO_CONTROLLER = "calendar-turbo"
        ACTIONS          = [
          "calendar:navigate->#{TURBO_CONTROLLER}#onNavigate",
          "turbo:before-fetch-response->#{TURBO_CONTROLLER}#onResponse",
          "turbo:frame-missing->#{TURBO_CONTROLLER}#onError",
          "turbo:fetch-request-error->#{TURBO_CONTROLLER}#onError",
          "#{TURBO_CONTROLLER}:failed->#{STIMULUS_CONTROLLER}#onFailed"
        ].join(" ").freeze

        # `url`: a base URL String, a Symbol naming a view method, or a Proc run on the view; nil uses the current URL.
        def initialize(template, url)
          super(template)
          @url = url
        end

        def stimulus_data(_configuration)
          {
            controller:                  TURBO_CONTROLLER,
            action:                      ACTIONS,
            "calendar-navigation-value" => "turbo"
          }
        end

        # The period in a Turbo Frame.
        def render(configuration)
          grid = grid_for(configuration)
          template.content_tag(:"turbo-frame", id: configuration.frame_id) do
            template.safe_join([Header.new(template).render(grid), grid.render])
          end
        end

        private

        attr_reader :url

        def grid_for(configuration)
          grid = { month: DaysOfMonth, year: MonthsOfYear, decade: YearsOfDecade }.fetch(configuration.view)
          grid.new(template, configuration, url_builder(configuration.id))
        end

        # Builds a period URL from a date and a view; nil disables the control.
        def url_builder(id)
          generator, init_args = url.nil? || url.is_a?(String) ? [PeriodUrl, [template, id, url]] : [url, []]
          lambda do |date, view|
            dispatcher = Plumber::Dispatcher.build(generator, date, view, method_name: :call, init_args: init_args)
            raise ArgumentError, "invalid url: #{url.inspect}" unless dispatcher

            dispatcher.call(template).presence
          end
        end
      end
    end
  end
end
