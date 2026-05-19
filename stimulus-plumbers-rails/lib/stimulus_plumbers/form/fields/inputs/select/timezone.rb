# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Select
          module Timezone
            def time_zone_select(attribute, priority_zones = nil, options = {}, html_options = {})
              html_native = options.delete(:html_native) { false }
              Field.new(@template, **options).render(object, attribute, input_id: field_id(attribute)) do |html_opts, opts, error|
                merged_html_opts = merge_html_options(html_options, html_opts, field_theme(:form_select, error: error))
                if html_native
                  super(attribute, priority_zones, opts, merged_html_opts)
                else
                  render_select_dropdown(attribute, opts, merged_html_opts, err: error) do
                    model = opts.delete(:model) { ActiveSupport::TimeZone }
                    build_zone_choices(priority_zones, model.all)
                  end
                end
              end
            end

            private

            def build_zone_choices(priority_zones, all_zones)
              return zone_options(all_zones) unless priority_zones

              priority       = filter_priority_zones(priority_zones, all_zones)
              priority_names = priority.to_set(&:name)
              remaining      = all_zones.reject { |z| priority_names.include?(z.name) }
              [
                {
                  label:   I18n.t("helpers.time_zone_select.priority_zones", default: "Suggested"),
                  options: zone_options(priority)
                },
                {
                  label:   I18n.t("helpers.time_zone_select.other_zones", default: "Other"),
                  options: zone_options(remaining)
                }
              ]
            end

            def filter_priority_zones(priority_zones, all_zones)
              case priority_zones
              when Regexp then all_zones.select { |z| z.name.match?(priority_zones) }
              else Array(priority_zones)
              end
            end

            def zone_options(zones)
              zones.map { |z| [z.to_s, z.name] }
            end
          end
        end
      end
    end
  end
end
