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

          # rubocop:disable Metrics/AbcSize
          def render_combobox_typeahead(attribute, html_opts, opts, error, url: nil, clearable: false, choices: [], **kwargs)
            current_value = object.respond_to?(attribute) ? object.public_send(attribute) : nil
            input_id      = html_opts[:id]
            labelledby    = Field.label_id(input_id)
            combobox_opts = Components::Combobox::Typeahead.default_opts.deep_merge(
              input:   { value: current_value },
              trigger: { data: clearable ? { input_clearable_target: "input" } : {}, aria: html_opts[:aria] },
              **opts
            )
            combobox_html = render_combobox(
              attribute,
              input_id: input_id,
              klass:    Components::Combobox::Typeahead,
              opts:     combobox_opts,
              err:      error,
              data:     {
                input_combobox_combobox_dropdown_outlet: "##{Components::Combobox.panel_id_for(input_id)}",
                action:                                  "input->input-combobox#onInput"
              },
              **kwargs
            ) do |panel_attrs|
              Components::Combobox::Typeahead.new(@template).render(
                panel_attrs: panel_attrs, options: choices, value: current_value, labelledby: labelledby, url: url
              )
            end

            return combobox_html unless clearable

            render_input_group(
              trailing: method(:clear_button),
              error:    !!error,
              **merge_html_options(field_theme(:form_input_clearable), { data: { controller: "input-clearable" } })
            ) { combobox_html }
          end
          # rubocop:enable Metrics/AbcSize

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
