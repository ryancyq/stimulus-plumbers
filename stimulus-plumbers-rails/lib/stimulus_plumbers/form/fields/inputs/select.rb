# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Select
          def select(attribute, choices = nil, options = {}, html_options = {})
            html_native   = options.delete(:html_native) { false }
            icon_leading  = options.delete(:icon_leading)
            icon_trailing = options.delete(:icon_trailing) { "chevron-down" }
            icons         = { icon_leading: icon_leading, icon_trailing: icon_trailing }
            with_select_field(attribute, options, html_options) do |opts, merged, error|
              if html_native
                super(attribute, choices, opts, merged)
              else
                render_select_dropdown(attribute, opts, merged, err: error, **icons) do
                  Array(choices)
                end
              end
            end
          end

          def collection_select(
            attribute,
            collection,
            value_method,
            text_method,
            options = {},
            html_options = {}
          )
            html_native   = options.delete(:html_native) { false }
            icon_leading  = options.delete(:icon_leading)
            icon_trailing = options.delete(:icon_trailing) { "chevron-down" }
            icons         = { icon_leading: icon_leading, icon_trailing: icon_trailing }
            with_select_field(attribute, options, html_options) do |opts, merged, error|
              if html_native
                super(attribute, collection, value_method, text_method, opts, merged)
              else
                render_select_dropdown(attribute, opts, merged, err: error, **icons) do
                  collection.map { |item| [item.public_send(text_method), item.public_send(value_method)] }
                end
              end
            end
          end

          private

          def with_select_field(attribute, options, html_options)
            Field.new(@template, **options).render(object, attribute, input_id: field_id(attribute)) do |html_opts, opts, error|
              yield opts, merge_html_options(html_options, html_opts, field_theme(:form_select, error: error)), error
            end
          end

          def render_select_dropdown(attribute, opts, html_opts, err:, icon_leading:, icon_trailing:)
            include_blank = opts.delete(:include_blank)
            prompt        = opts.delete(:prompt)
            current_value = opts.delete(:selected) { object.respond_to?(attribute) ? object.public_send(attribute) : nil }
            choices       = build_select_dropdown_choices(yield(current_value), include_blank: include_blank, prompt: prompt)
            combobox_opts = build_select_dropdown_opts(
              html_opts,
              current_value,
              icon_leading:  icon_leading,
              icon_trailing: icon_trailing
            )
            render_combobox(attribute, input_id: html_opts[:id], opts: combobox_opts, err: err) do
              render_dropdown_component(choices, current_value, html_opts[:id])
            end
          end

          def render_dropdown_component(choices, value, input_id)
            Components::Combobox::Dropdown.new(@template).render(
              options:    choices,
              value:      value,
              labelledby: Field.label_id(input_id)
            )
          end

          def build_select_dropdown_opts(html_opts, current_value, icon_leading:, icon_trailing:)
            Components::Combobox::Dropdown.default_opts.deep_merge(
              input:   { value: current_value },
              trigger: html_opts.merge({ icon_leading: icon_leading, icon_trailing: icon_trailing }.compact)
            )
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
