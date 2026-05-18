# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Search
          def search_field(attribute, options = {})
            rails_opts, form_field_opts = extract_options(options)
            url           = rails_opts.delete(:url) { nil }
            choices       = rails_opts.delete(:options) { [] }
            clearable     = form_field_opts.delete(:clearable) { false }
            field         = build_field(attribute, form_field_opts)
            current_value = object&.public_send(attribute)
            popover_id    = "#{field_id(attribute)}_popover"

            opts = Components::Combobox::Autocomplete.default_opts.deep_merge(
              input:   { value: current_value },
              trigger: { data: clearable ? { "input_search_target": "input" } : {} },
              popover: { data: url ? { combobox_dropdown_url_value: url } : {} }
            )

            combobox_html = render_combobox(
              attribute,
              field,
              opts,
              wrapper_data: {
                input_combobox_combobox_dropdown_outlet: "##{popover_id}",
                action:                                  "input->input-combobox#onInput"
              }
            ) { Components::Combobox::Autocomplete.new(@template).render(options: choices, value: current_value) }

            input_html = if clearable
                           wrapper_opts = merge_html_options(
                             field_theme(:form_input_search),
                             { "data-controller": "input-search" }
                           )
                           @template.content_tag(:div, combobox_html + clear_button, **wrapper_opts)
                         else
                           combobox_html
                         end

            render_field(field, input_html)
          end

          private

          def clear_button
            html_options = merge_html_options(
              field_theme(:form_button_clear),
              {
                type:                        "button",
                "aria-label":                "Clear search",
                "data-input-search-target":  "clear",
                "data-action":               "click->input-search#clear",
                hidden:                      true
              }
            )
            @template.content_tag(:button, "", **html_options)
          end
        end
      end
    end
  end
end
