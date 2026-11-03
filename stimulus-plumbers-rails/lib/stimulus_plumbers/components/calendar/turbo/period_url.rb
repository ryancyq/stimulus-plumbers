# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar
      class Turbo
        # The default period URL: `url`, or the current URL, plus <id>[displayed] and <id>[view].
        class PeriodUrl < Plumber::Base
          def initialize(template, id, url = nil)
            super(template)
            @id = id
            path, query = url ? URI.parse(url).then { |uri| [uri.path, uri.query] } : current_path_and_query
            @path  = path.sub(%r{\A/+}, "/") # a leading // would link to another host
            @query = Rack::Utils.parse_nested_query(query)
          end

          def call(displayed, view)
            "#{@path}?#{@query.deep_merge(@id => { "displayed" => displayed.iso8601, "view" => view.to_s }).to_query}"
          end

          private

          # The request path and query string as sent; never parsed as a URI.
          def current_path_and_query
            [template.request.path, template.request.query_string]
          end
        end
      end
    end
  end
end
