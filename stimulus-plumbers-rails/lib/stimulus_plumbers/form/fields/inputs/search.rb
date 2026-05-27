# frozen_string_literal: true

require_relative "combobox"

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Search
          include Combobox

          def search_field(attribute, options = {})
            clearable    = options.delete(:clearable) { false }
            data         = clearable ? { data: { input_clearable_target: "input" } } : {}
            html_options = merge_html_options(options, field_theme(:form_input), data)
            input_html   = super(attribute, html_options)
            return input_html unless clearable

            render_input_group(
              trailing: method(:clear_button),
              error:    false,
              **merge_html_options(field_theme(:form_input_clearable), { data: { controller: "input-clearable" } })
            ) { input_html }
          end

          private

          # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          def render_combobox_typeahead(attribute, html_opts, _opts, error, url: nil, clearable: false, choices: [], **_)
            current_value = object.respond_to?(attribute) ? object.public_send(attribute) : nil
            input_id      = html_opts[:id]
            combobox_opts = Components::Combobox::Typeahead.default_opts.deep_merge(
              input:   { value: current_value },
              trigger: { data: clearable ? { input_clearable_target: "input" } : {}, aria: html_opts[:aria] },
              popover: { data: url ? { combobox_dropdown_url_value: url } : {} }
            )
            combobox_html = render_combobox(
              attribute,
              input_id: input_id,
              opts:     combobox_opts,
              err:      error,
              data:     {
                input_combobox_combobox_dropdown_outlet: "##{Components::Combobox.popover_id_for(input_id)}",
                action:                                  "input->input-combobox#onInput"
              }
            ) { Components::Combobox::Typeahead.new(@template).render(options: choices, value: current_value, labelledby: Field.label_id(input_id)) }

            return combobox_html unless clearable

            render_input_group(
              trailing: method(:clear_button),
              error:    !!error,
              **merge_html_options(field_theme(:form_input_clearable), { data: { controller: "input-clearable" } })
            ) { combobox_html }
          end
          # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

          def clear_button
            Components::Button.new(@template).render(
              icon_leading: "close",
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
