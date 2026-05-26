# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Select
          module Weekday
            if ActionView.version >= Gem::Version.new("7.1")
              def weekday_select(attribute, options = {}, html_options = {})
                html_native   = options.delete(:html_native) { false }
                icon_leading  = options.delete(:icon_leading)
                icon_trailing = options.delete(:icon_trailing) { "chevron-down" }
                icons         = { icon_leading: icon_leading, icon_trailing: icon_trailing }
                with_select_field(attribute, options, html_options) do |opts, merged, error|
                  if html_native
                    super(attribute, opts, merged)
                  else
                    render_select_dropdown(attribute, opts, merged, err: error, **icons) do
                      build_weekday_choices(opts)
                    end
                  end
                end
              end
            end

            private

            def build_weekday_choices(opts)
              index_as_value    = opts.delete(:index_as_value) { false }
              day_format        = opts.delete(:day_format) { :day_names }
              beginning_of_week = opts.delete(:beginning_of_week) { Date.beginning_of_week }

              day_names = I18n.t("date.#{day_format}")
              choices   = day_names.each_with_index.map { |name, i| index_as_value ? [name, i] : [name, name] }
              choices.rotate(Date::DAYS_INTO_WEEK.fetch(beginning_of_week))
            end
          end
        end
      end
    end
  end
end
