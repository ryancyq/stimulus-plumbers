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
                data         = clearable ? { data: { input_search_target: "input" } } : {}
                html_options = merge_html_options(opts, html_opts, field_theme(:form_input, error: error), data)
                input_html   = super(attribute, html_options)
                clearable ? wrap_input_search(input_html) : input_html
              else
                render_search_combobox(attribute, html_opts, error, url: url, choices: choices, clearable: clearable)
              end
            end
          end

          private

          def render_search_combobox(attribute, html_opts, error, url:, choices:, clearable:)
            current_value = object&.public_send(attribute)
            input_id      = html_opts[:id]
            opts          = Components::Combobox::Autocomplete.default_opts.deep_merge(
              input:   { value: current_value },
              trigger: { data: clearable ? { input_search_target: "input" } : {}, aria: html_opts[:aria] },
              popover: { data: url ? { combobox_dropdown_url_value: url } : {} }
            )
            combobox_html = render_combobox(
              attribute,
              input_id: input_id,
              opts:     opts,
              err:      error,
              data:     { input_combobox_combobox_dropdown_outlet: "##{Components::Combobox.popover_id_for(input_id)}", action: "input->input-combobox#onInput" }
            ) { Components::Combobox::Autocomplete.new(@template).render(options: choices, value: current_value) }

            clearable ? wrap_input_search(combobox_html) : combobox_html
          end

          def wrap_input_search(content)
            wrapper_opts = merge_html_options(
              field_theme(:form_input_search),
              { data: { controller: "input-search" } }
            )
            @template.content_tag(:div, @template.safe_join([content, clear_button]), **wrapper_opts)
          end

          def clear_button
            html_options = merge_html_options(
              field_theme(:form_button_clear),
              {
                type:   "button",
                aria:   { label: "Clear search" },
                hidden: true,
                data:         { input_search_target: "clear", action: "click->input-search#clear" }
              }
            )
            @template.content_tag(:button, "", **html_options)
          end
        end
      end
    end
  end
end
