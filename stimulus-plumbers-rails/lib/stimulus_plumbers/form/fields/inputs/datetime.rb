# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Datetime
          def date_field(attribute, options = {})
            html_native = options.delete(:html_native) { false }
            Field.new(@template, **options).render(
              object,
              attribute,
              input_id: field_id(attribute)
            ) do |html_opts, opts, error|
              if html_native
                html_options = merge_html_options(opts, html_opts, field_theme(:form_input, error: error))
                super(attribute, html_options)
              else
                render_date_combobox(attribute, html_opts, error)
              end
            end
          end

          def time_field(attribute, options = {})
            html_native = options.delete(:html_native) { false }
            format      = options.delete(:format) { :h12 }
            step        = options.delete(:step) { 1 }
            Field.new(@template, **options).render(
              object,
              attribute,
              input_id: field_id(attribute)
            ) do |html_opts, opts, error|
              if html_native
                html_options = merge_html_options(opts, html_opts, field_theme(:form_input, error: error))
                super(attribute, html_options)
              else
                render_time_combobox(attribute, html_opts, error, format: format, step: step)
              end
            end
          end

          private

          def render_date_combobox(attribute, html_opts, error)
            current_value = object.respond_to?(attribute) ? object.public_send(attribute) : nil
            opts = Components::Combobox::Date.default_opts.deep_merge(
              input:   { value: current_value, data: { combobox_date_date_value: current_value } },
              trigger: { aria: html_opts[:aria] }
            )
            render_combobox(
              attribute,
              input_id: html_opts[:id],
              opts:     opts,
              err:      error,
              data:     { input_format_type_value: "date" }
            ) do |popover_id|
              Components::Combobox::Date.new(@template).render(value: current_value, popover_id: popover_id)
            end
          end

          def render_time_combobox(attribute, html_opts, error, format:, step:)
            current_value = object.respond_to?(attribute) ? object.public_send(attribute) : nil
            opts = Components::Combobox::Time.default_opts.deep_merge(
              input:   { value: current_value },
              trigger: { aria: html_opts[:aria] }
            )
            render_combobox(
              attribute,
              input_id: html_opts[:id],
              opts:     opts,
              err:      error,
              data:     { input_format_type_value: "time", input_format_options_value: { format: format }.to_json }
            ) { Components::Combobox::Time.new(@template).render(format: format, step: step, value: current_value) }
          end
        end
      end
    end
  end
end
