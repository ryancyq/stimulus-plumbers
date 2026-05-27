# frozen_string_literal: true

require_relative "combobox"

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Datetime
          include Combobox

          def date_field(attribute, options = {})
            html_options = merge_html_options(options, field_theme(:form_input))
            super(attribute, html_options)
          end

          def time_field(attribute, options = {})
            html_options = merge_html_options(options, field_theme(:form_input))
            super(attribute, html_options)
          end

          private

          def render_combobox_date(attribute, html_opts, _opts, error, icon_leading: nil, icon_trailing: "calendar", **_)
            current_value = object.respond_to?(attribute) ? object.public_send(attribute) : nil
            opts = Components::Combobox::Date.default_opts.deep_merge(
              input:   { value: current_value, data: { combobox_date_date_value: current_value } },
              trigger: { aria: html_opts[:aria], icon_leading: icon_leading, icon_trailing: icon_trailing }.compact,
              popover: { labelledby: Field.label_id(html_opts[:id]) }
            )
            render_combobox(
              attribute,
              input_id: html_opts[:id],
              opts:     opts,
              err:      error,
              data:     { input_formatter_format_value: "date" }
            ) do |popover_id|
              Components::Combobox::Date.new(@template).render(value: current_value, popover_id: popover_id)
            end
          end

          def render_combobox_time(attribute, html_opts, _opts, error, format: :h12, step: 1, icon_leading: nil, icon_trailing: "clock", **_)
            current_value = object.respond_to?(attribute) ? object.public_send(attribute) : nil
            opts = Components::Combobox::Time.default_opts.deep_merge(
              input:   { value: current_value },
              trigger: { aria: html_opts[:aria], icon_leading: icon_leading, icon_trailing: icon_trailing }.compact,
              popover: { labelledby: Field.label_id(html_opts[:id]) }
            )
            render_combobox(
              attribute,
              input_id: html_opts[:id],
              opts:     opts,
              err:      error,
              data:     { input_formatter_format_value: "time", input_formatter_options_value: { format: format }.to_json }
            ) { Components::Combobox::Time.new(@template).render(format: format, step: step, value: current_value) }
          end
        end
      end
    end
  end
end
