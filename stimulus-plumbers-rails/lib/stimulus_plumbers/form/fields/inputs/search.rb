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
            field         = build_field(attribute, form_field_opts)
            current_value = object&.public_send(attribute)
            popover_id    = "#{field_id(attribute)}_popover"

            opts = Components::Combobox::Autocomplete.default_opts.deep_merge(
              input:   { value: current_value },
              popover: { data: url ? { combobox_dropdown_url_value: url } : {} }
            )

            render_field(
              field,
              render_combobox(
                attribute,
                field,
                opts,
                wrapper_data: {
                  input_combobox_combobox_dropdown_outlet: "##{popover_id}",
                  action:                                  "input->input-combobox#onInput"
                }
              ) { Components::Combobox::Autocomplete.new(@template).render(options: choices, value: current_value) }
            )
          end
        end
      end
    end
  end
end
