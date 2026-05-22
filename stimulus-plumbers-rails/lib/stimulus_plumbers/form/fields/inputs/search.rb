# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Search
          def search_field(attribute, options = {})
            html_native = options.delete(:html_native) { false }
            clearable   = options.delete(:clearable) { false }
            url         = options.delete(:url) { nil }
            choices     = options.delete(:options) { [] }

            Field.new(@template, **options).render(
              object,
              attribute,
              input_id: field_id(attribute)
            ) do |html_opts, opts, error|
              if html_native
                render_search_input(html_opts, opts, error, clearable: clearable) do |html_options|
                  super(attribute, html_options)
                end
              else
                render_search_combobox(
                  attribute,
                  html_opts,
                  error,
                  url:       url,
                  clearable: clearable
                ) do |combobox_opts, input_id, current_value|
                  render_search_autocomplete(attribute, input_id, combobox_opts, error, choices, current_value)
                end
              end
            end
          end

          private

          def render_search_input(html_opts, opts, error, clearable:, &block)
            data         = clearable ? { data: { input_clearable_target: "input" } } : {}
            html_options = merge_html_options(opts, html_opts, field_theme(:form_input, error: error), data)
            input_html   = @template.capture(html_options, &block)

            return input_html unless clearable

            render_input_group(
              trailing: method(:clear_button),
              error:    !!error,
              **merge_html_options(field_theme(:form_input_clearable), { data: { controller: "input-clearable" } })
            ) { input_html }
          end

          def render_search_combobox(attribute, html_opts, error, url:, clearable:, &block)
            current_value = object.respond_to?(attribute) ? object.public_send(attribute) : nil
            input_id      = html_opts[:id]
            opts          = Components::Combobox::Autocomplete.default_opts.deep_merge(
              input:   { value: current_value },
              trigger: { data: clearable ? { input_clearable_target: "input" } : {}, aria: html_opts[:aria] },
              popover: { data: url ? { combobox_dropdown_url_value: url } : {} }
            )

            combobox_html = @template.capture(opts, input_id, current_value, &block)
            return combobox_html unless clearable

            render_input_group(
              trailing: method(:clear_button),
              error:    !!error,
              **merge_html_options(field_theme(:form_input_clearable), { data: { controller: "input-clearable" } })
            ) { combobox_html }
          end

          def render_search_autocomplete(attribute, input_id, combobox_opts, error, choices, current_value)
            render_combobox(
              attribute,
              input_id: input_id,
              opts:     combobox_opts,
              err:      error,
              data:     {
                input_combobox_combobox_dropdown_outlet: "##{Components::Combobox.popover_id_for(input_id)}",
                action:                                  "input->input-combobox#onInput"
              }
            ) { Components::Combobox::Autocomplete.new(@template).render(options: choices, value: current_value, labelledby: Field.label_id(input_id)) }
          end

          def clear_button
            Components::Button.new(@template).render(
              "",
              **merge_html_options(
                field_theme(:form_button_clear),
                {
                  aria:   { label: "Clear search" },
                  hidden: true,
                  data:   { input_clearable_target: "clear", action: "click->input-clearable#clear" }
                }
              )
            )
          end
        end
      end
    end
  end
end
