# frozen_string_literal: true

require_relative "combobox"

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Select
          include Combobox

          def select(attribute, choices = nil, options = {}, html_options = {})
            merged = merge_html_options(theme.resolve(:form_field_input_select), html_options)
            super(attribute, choices, options, merged)
          end

          def collection_select(attribute, collection, value_method, text_method, options = {}, html_options = {})
            merged = merge_html_options(theme.resolve(:form_field_input_select), html_options)
            super(attribute, collection, value_method, text_method, options, merged)
          end

          private

          def render_combobox_dropdown(
            attribute,
            html_opts,
            opts,
            error,
            icon_leading: nil,
            icon_trailing: nil,
            choices: [],
            include_blank: nil,
            prompt: nil,
            selected: nil,
            **kwargs
          )
            current_value = selected || (object.respond_to?(attribute) ? object.public_send(attribute) : nil)
            all_choices   = build_select_dropdown_choices(Array(choices), include_blank: include_blank, prompt: prompt)
            labelledby    = Field.label_id(html_opts[:id])
            combobox_opts = build_select_dropdown_opts(
              html_opts, current_value, opts: opts, icon_leading: icon_leading, icon_trailing: icon_trailing
            )
            render_combobox(
              attribute,
              input_id: html_opts[:id],
              opts:     combobox_opts,
              error:    error
            ) do |c|
              c.dropdown(options: all_choices, value: current_value, labelledby: labelledby, **kwargs)
            end
          end

          def render_collection_combobox_dropdown(
            attribute,
            collection,
            value_method,
            text_method,
            field_opts,
            **kwargs
          )
            choices = collection.map { |item| [item.public_send(text_method), item.public_send(value_method)] }
            render_field(:select, attribute, field_opts, { choices: choices, **kwargs })
          end

          def render_grouped_collection_combobox_dropdown(
            attribute,
            collection,
            value_method,
            text_method,
            field_opts,
            group_method:,
            group_label_method:,
            **kwargs
          )
            choices = build_grouped_choices(collection, group_label_method, group_method, value_method, text_method)
            render_field(:select, attribute, field_opts, { choices: choices, **kwargs })
          end

          def build_select_dropdown_opts(html_opts, current_value, opts:, icon_leading:, icon_trailing:)
            {
              input:   { value: current_value },
              trigger: { aria: html_opts[:aria], icon_leading: icon_leading, icon_trailing: icon_trailing }.compact,
              **opts
            }
          end

          def build_select_dropdown_choices(choices, include_blank:, prompt:)
            return choices unless include_blank || prompt

            choices = choices.dup
            choices.unshift([include_blank.is_a?(String) ? include_blank : "", ""]) if include_blank
            choices.unshift(build_select_dropdown_choice_prompt(prompt)) if prompt
            choices
          end

          def build_select_dropdown_choice_prompt(prompt)
            label = prompt.is_a?(String) ? prompt : I18n.t("helpers.select.prompt", default: "Please select")
            [label, "", { disabled: true }]
          end
        end
      end
    end
  end
end
