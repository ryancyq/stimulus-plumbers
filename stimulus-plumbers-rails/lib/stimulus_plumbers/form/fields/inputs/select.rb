# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Select
          def select(attribute, choices = nil, options = {}, html_options = {})
            html_native = options.delete(:html_native) { false }
            Field.new(@template, **options).render(
              object,
              attribute,
              input_id: field_id(attribute)
            ) do |html_opts, opts, error|
              merged_html_opts = merge_html_options(html_options, html_opts, field_theme(:form_select, error: error))
              if html_native
                super(attribute, choices, opts, merged_html_opts)
              else
                render_dropdown(attribute, opts, merged_html_opts, err: error) { Array(choices) }
              end
            end
          end

          def collection_select(
            attribute,
            collection,
            value_method,
            text_method,
            options = {},
            html_options = {}
          )
            html_native = options.delete(:html_native) { false }
            Field.new(@template, **options).render(
              object,
              attribute,
              input_id: field_id(attribute)
            ) do |html_opts, opts, error|
              merged_html_opts = merge_html_options(html_options, html_opts, field_theme(:form_select, error: error))
              if html_native
                super(attribute, collection, value_method, text_method, opts, merged_html_opts)
              else
                render_dropdown(attribute, opts, merged_html_opts, err: error) do
                  collection.map { |item| [item.public_send(text_method), item.public_send(value_method)] }
                end
              end
            end
          end

          def grouped_collection_select(
            attribute,
            collection,
            group_method,
            group_label_method,
            option_key_method,
            option_value_method,
            options = {},
            html_options = {}
          )
            html_native = options.delete(:html_native) { false }
            Field.new(@template, **options).render(
              object,
              attribute,
              input_id: field_id(attribute)
            ) do |html_opts, opts, error|
              merged_html_opts = merge_html_options(html_options, html_opts, field_theme(:form_select, error: error))
              if html_native
                super(
                  attribute,
                  collection,
                  group_method,
                  group_label_method,
                  option_key_method,
                  option_value_method,
                  opts,
                  merged_html_opts
                )
              else
                render_dropdown(attribute, opts, merged_html_opts, err: error) do
                  collection.map do |group|
                    {
                      label:   group.public_send(group_label_method),
                      options: group.public_send(group_method).map do |item|
                        [item.public_send(option_value_method), item.public_send(option_key_method)]
                      end
                    }
                  end
                end
              end
            end
          end

          def time_zone_select(attribute, priority_zones = nil, options = {}, html_options = {})
            html_native = options.delete(:html_native) { false }
            Field.new(@template, **options).render(
              object,
              attribute,
              input_id: field_id(attribute)
            ) do |html_opts, opts, error|
              merged_html_opts = merge_html_options(html_options, html_opts, field_theme(:form_select, error: error))
              if html_native
                super(attribute, priority_zones, opts, merged_html_opts)
              else
                render_dropdown(attribute, opts, merged_html_opts, err: error) do
                  model = opts.delete(:model) { ActiveSupport::TimeZone }
                  build_zone_choices(priority_zones, model.all)
                end
              end
            end
          end

          if ActionView.version >= Gem::Version.new("7.1")
            def weekday_select(attribute, options = {}, html_options = {})
              html_native = options.delete(:html_native) { false }
              Field.new(@template, **options).render(
                object,
                attribute,
                input_id: field_id(attribute)
              ) do |html_opts, opts, error|
                merged_html_opts = merge_html_options(html_options, html_opts, field_theme(:form_select, error: error))
                if html_native
                  super(attribute, opts, merged_html_opts)
                else
                  render_dropdown(attribute, opts, merged_html_opts, err: error) do
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

          private

          def render_dropdown(attribute, opts, html_opts, err:)
            include_blank = opts.delete(:include_blank)
            prompt        = opts.delete(:prompt)
            current_value = opts.delete(:selected) { object&.public_send(attribute) }
            choices = yield(current_value)
            choices = choices.dup if include_blank || prompt
            choices.unshift([include_blank.is_a?(String) ? include_blank : "", ""]) if include_blank
            if prompt
              choices.unshift(
                [
                  prompt.is_a?(String) ? prompt : I18n.t("helpers.select.prompt", default: "Please select"), "",
                  { disabled: true }
                ]
              )
            end

            dropdown_opts = Components::Combobox::Dropdown.default_opts.deep_merge(
              input:   { value: current_value },
              trigger: html_opts
            )
            render_combobox(attribute, input_id: html_opts[:id], opts: dropdown_opts, err: err) do
              Components::Combobox::Dropdown.new(@template).render(options: choices, value: current_value)
            end
          end

          def build_zone_choices(priority_zones, all_zones)
            return all_zones.map { |z| [z.to_s, z.name] } unless priority_zones

            priority = case priority_zones
                       when Regexp then all_zones.select { |z| z.name.match?(priority_zones) }
                       else Array(priority_zones)
                       end
            priority_names = priority.to_set(&:name)
            remaining      = all_zones.reject { |z| priority_names.include?(z.name) }
            [
              {
                label:   I18n.t("helpers.time_zone_select.priority_zones", default: "Suggested"),
                options: priority.map { |z| [z.to_s, z.name] }
              },
              {
                label:   I18n.t("helpers.time_zone_select.other_zones", default: "Other"),
                options: remaining.map { |z| [z.to_s, z.name] }
              }
            ]
          end
        end
      end
    end
  end
end
