# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Datetime
          def date_field(attribute, options = {})
            html_options = merge_html_options(theme.resolve(:form_field_input), options)
            super(attribute, html_options)
          end

          def time_field(attribute, options = {})
            html_options = merge_html_options(theme.resolve(:form_field_input), options)
            super(attribute, html_options)
          end

          private

          def render_combobox_date(
            attribute,
            html_opts,
            opts,
            error,
            floating: nil,
            icon_leading: nil,
            icon_trailing: nil,
            **kwargs
          )
            current_value = object.respond_to?(attribute) ? object.public_send(attribute) : nil
            labelledby    = Field.label_id(html_opts[:id])
            combobox_opts = {
              input:   { value: current_value },
              trigger: { aria: html_opts[:aria], icon_leading: icon_leading, icon_trailing: icon_trailing }.compact,
              **opts
            }
            render_legacy_combobox(
              attribute,
              input_id: html_opts[:id],
              opts:     combobox_opts,
              error:    error,
              floating: floating,
              **kwargs
            ) do |c|
              c.date(value: current_value, labelledby: labelledby)
            end
          end

          def render_legacy_combobox(attribute, input_id:, opts:, error:, floating: nil, **kwargs, &block)
            Components::Combobox::Legacy.new(@template).render(
              id: input_id,
              **opts.deep_merge(input: { name: field_name(attribute) }),
              **merge_html_options(theme.resolve(:form_field_input_combobox, floating: floating, error: error), kwargs),
              &block
            )
          end

          def render_combobox_time(
            attribute,
            html_opts,
            opts,
            error,
            floating: nil,
            format: :h12,
            step: 1,
            icon_leading: nil,
            icon_trailing: nil,
            **kwargs
          )
            current_value = object.respond_to?(attribute) ? object.public_send(attribute) : nil
            labelledby    = Field.label_id(html_opts[:id])
            combobox_opts = {
              input:   { value: current_value },
              trigger: { aria: html_opts[:aria], icon_leading: icon_leading, icon_trailing: icon_trailing }.compact,
              **opts
            }
            render_legacy_combobox(
              attribute,
              input_id: html_opts[:id],
              opts:     combobox_opts,
              error:    error,
              floating: floating,
              **kwargs
            ) do |c|
              c.time(format: format, step: step, value: current_value, labelledby: labelledby)
            end
          end
        end
      end
    end
  end
end
