# frozen_string_literal: true

require_relative "combobox"

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Datetime
          include Combobox

          def date_field(attribute, options = {})
            html_options = merge_html_options(theme.resolve(:form_field_input), options)
            super(attribute, html_options)
          end

          def time_field(attribute, options = {})
            html_options = merge_html_options(theme.resolve(:form_field_input), options)
            super(attribute, html_options)
          end

          private

          def render_combobox_date(attribute, html_opts, opts, error, icon_leading: nil, icon_trailing: "calendar", **kwargs)
            current_value = object.respond_to?(attribute) ? object.public_send(attribute) : nil
            labelledby    = Field.label_id(html_opts[:id])
            combobox_opts = Components::Combobox::Date.options(
              input:   { value: current_value, data: { combobox_date_date_value: current_value } },
              trigger: { aria: html_opts[:aria], icon_leading: icon_leading, icon_trailing: icon_trailing }.compact,
              **opts
            )
            render_combobox(
              attribute,
              input_id: html_opts[:id],
              variant:  Components::Combobox::Date.variant,
              opts:     combobox_opts,
              error:    error,
              data:     { input_formatter_format_value: "date" },
              **kwargs
            ) do |panel_attrs|
              Components::Combobox::Date.new(@template).render(
                panel_attrs: panel_attrs, value: current_value, labelledby: labelledby
              )
            end
          end

          def render_combobox_time(
            attribute,
            html_opts,
            opts,
            error,
            format: :h12,
            step: 1,
            icon_leading: nil,
            icon_trailing: "clock",
            **kwargs
          )
            current_value = object.respond_to?(attribute) ? object.public_send(attribute) : nil
            labelledby    = Field.label_id(html_opts[:id])
            combobox_opts = Components::Combobox::Time.options(
              input:   { value: current_value },
              trigger: { aria: html_opts[:aria], icon_leading: icon_leading, icon_trailing: icon_trailing }.compact,
              **opts
            )
            render_combobox(
              attribute,
              input_id: html_opts[:id],
              variant:  Components::Combobox::Time.variant,
              opts:     combobox_opts,
              error:    error,
              data:     { input_formatter_format_value: "time", input_formatter_options_value: { format: format }.to_json },
              **kwargs
            ) do |panel_attrs|
              Components::Combobox::Time.new(@template).render(
                panel_attrs: panel_attrs, format: format, step: step, value: current_value, labelledby: labelledby
              )
            end
          end
        end
      end
    end
  end
end
