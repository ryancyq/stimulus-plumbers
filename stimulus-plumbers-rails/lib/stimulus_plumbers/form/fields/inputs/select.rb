# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Select
          def select(attribute, choices = nil, options = {}, html_options = {})
            rails_opts, form_field_opts = extract_options(options)
            html_native = form_field_opts.delete(:html_native) { false }
            field       = build_field(attribute, form_field_opts)

            if html_native
              select_html = merge_html_options(html_options, field_theme(:form_select, error: field.error?), field.html_options)
              render_field(field, super(attribute, choices, rails_opts, select_html))
            else
              current_value = object&.public_send(attribute)
              opts = Components::Combobox::Dropdown.default_opts.deep_merge(input: { value: current_value })
              render_field(
                field,
                render_combobox(attribute, field, opts, html_options: html_options) do
                  Components::Combobox::Dropdown.new(@template).render(options: Array(choices), value: current_value)
                end
              )
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
            rails_opts, form_field_opts = extract_options(options)
            html_native = form_field_opts.delete(:html_native) { false }
            field       = build_field(attribute, form_field_opts)

            if html_native
              select_html = merge_html_options(html_options, field_theme(:form_select, error: field.error?), field.html_options)
              render_field(field, super(attribute, collection, value_method, text_method, rails_opts, select_html))
            else
              current_value = object&.public_send(attribute)
              choices       = collection.map { |item| [item.public_send(text_method), item.public_send(value_method)] }
              opts = Components::Combobox::Dropdown.default_opts.deep_merge(input: { value: current_value })
              render_field(
                field,
                render_combobox(attribute, field, opts, html_options: html_options) do
                  Components::Combobox::Dropdown.new(@template).render(options: choices, value: current_value)
                end
              )
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
            rails_opts, form_field_opts = extract_options(options)
            html_native = form_field_opts.delete(:html_native) { false }
            field       = build_field(attribute, form_field_opts)

            if html_native
              select_html = merge_html_options(html_options, field_theme(:form_select, error: field.error?), field.html_options)
              render_field(field, super(attribute, collection, group_method, group_label_method,
                                       option_key_method, option_value_method, rails_opts, select_html))
            else
              current_value = object&.public_send(attribute)
              choices       = collection.map do |group|
                {
                  label:   group.public_send(group_label_method),
                  options: group.public_send(group_method).map do |item|
                    [item.public_send(option_value_method), item.public_send(option_key_method)]
                  end
                }
              end
              opts = Components::Combobox::Dropdown.default_opts.deep_merge(input: { value: current_value })
              render_field(
                field,
                render_combobox(attribute, field, opts, html_options: html_options) do
                  Components::Combobox::Dropdown.new(@template).render(options: choices, value: current_value)
                end
              )
            end
          end

          def time_zone_select(attribute, priority_zones = nil, options = {}, html_options = {})
            rails_opts, form_field_opts = extract_options(options)
            html_native = form_field_opts.delete(:html_native) { false }
            field       = build_field(attribute, form_field_opts)

            if html_native
              select_html = merge_html_options(html_options, field_theme(:form_select, error: field.error?), field.html_options)
              render_field(field, super(attribute, priority_zones, rails_opts, select_html))
            else
              current_value = object&.public_send(attribute)
              model         = rails_opts.delete(:model) { ActiveSupport::TimeZone }
              all_zones     = model.all

              choices = if priority_zones
                priority = case priority_zones
                           when Regexp then all_zones.select { |z| z.name.match?(priority_zones) }
                           else Array(priority_zones)
                           end
                priority_names = priority.map(&:name).to_set
                remaining      = all_zones.reject { |z| priority_names.include?(z.name) }
                [
                  { label: I18n.t("helpers.time_zone_select.priority_zones", default: "Suggested"),
                    options: priority.map { |z| [z.to_s, z.name] } },
                  { label: I18n.t("helpers.time_zone_select.other_zones", default: "Other"),
                    options: remaining.map { |z| [z.to_s, z.name] } }
                ]
              else
                all_zones.map { |z| [z.to_s, z.name] }
              end

              opts = Components::Combobox::Dropdown.default_opts.deep_merge(input: { value: current_value })
              render_field(
                field,
                render_combobox(attribute, field, opts, html_options: html_options) do
                  Components::Combobox::Dropdown.new(@template).render(options: choices, value: current_value)
                end
              )
            end
          end

          if ActionView.version >= Gem::Version.new("7.1")
            def weekday_select(attribute, options = {}, html_options = {})
              rails_opts, form_field_opts = extract_options(options)
              html_native = form_field_opts.delete(:html_native) { false }
              field       = build_field(attribute, form_field_opts)

              if html_native
                select_html = merge_html_options(html_options, field_theme(:form_select, error: field.error?), field.html_options)
                render_field(field, super(attribute, rails_opts, select_html))
              else
                current_value     = object&.public_send(attribute)
                index_as_value    = rails_opts.delete(:index_as_value) { false }
                day_format        = rails_opts.delete(:day_format) { :day_names }
                beginning_of_week = rails_opts.delete(:beginning_of_week) { Date.beginning_of_week }

                day_names = I18n.t("date.#{day_format}")
                choices   = day_names.each_with_index.map { |name, i| index_as_value ? [name, i] : [name, name] }
                choices   = choices.rotate(Date::DAYS_INTO_WEEK.fetch(beginning_of_week))

                opts = Components::Combobox::Dropdown.default_opts.deep_merge(input: { value: current_value })
                render_field(
                  field,
                  render_combobox(attribute, field, opts, html_options: html_options) do
                    Components::Combobox::Dropdown.new(@template).render(options: choices, value: current_value)
                  end
                )
              end
            end
          end
        end
      end
    end
  end
end
