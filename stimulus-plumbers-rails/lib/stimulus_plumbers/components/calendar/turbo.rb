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

        # `url` is the base of the period URLs; nil uses the current URL.
        def initialize(template, url)
          super(template)
          @url = url
        end

        def root_data(_configuration)
          {
            controller:                  TURBO_CONTROLLER,
            action:                      ACTIONS,
            "calendar-navigation-value" => "turbo",
            "calendar-url-value"        => url
          }.compact
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
          grid.new(template, configuration, period_link(configuration.id))
        end

        # `url`, or the current URL, plus <id>[displayed] and <id>[view].
        def period_link(id)
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
      end
    end
  end
end
