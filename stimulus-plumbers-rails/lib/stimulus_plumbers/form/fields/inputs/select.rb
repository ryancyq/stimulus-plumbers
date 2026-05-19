# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Select
          def select(attribute, choices = nil, options = {}, html_options = {})
            html_native = options.delete(:html_native) { false }
            Field.new(@template, **options).render(
              object,
              attribute,
              input_id: field_id(attribute)
            ) do |html_opts, opts, error|
              merged_html_opts = merge_html_options(html_options, html_opts, field_theme(:form_select, error: error))
              if html_native
                super(attribute, choices, opts, merged_html_opts)
              else
                render_dropdown(attribute, opts, merged_html_opts, err: error) { Array(choices) }
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
            html_native = options.delete(:html_native) { false }
            Field.new(@template, **options).render(
              object,
              attribute,
              input_id: field_id(attribute)
            ) do |html_opts, opts, error|
              merged_html_opts = merge_html_options(html_options, html_opts, field_theme(:form_select, error: error))
              if html_native
                super(attribute, collection, value_method, text_method, opts, merged_html_opts)
              else
                render_dropdown(attribute, opts, merged_html_opts, err: error) do
                  collection.map { |item| [item.public_send(text_method), item.public_send(value_method)] }
                end
              end
            end
          end

          private

          def render_dropdown(attribute, opts, html_opts, err:)
            include_blank = opts.delete(:include_blank)
            prompt        = opts.delete(:prompt)
            current_value = opts.delete(:selected) { object.respond_to?(attribute) ? object.public_send(attribute) : nil }
            choices       = build_dropdown_choices(yield(current_value), include_blank: include_blank, prompt: prompt)

            dropdown_opts = Components::Combobox::Dropdown.default_opts.deep_merge(
              input:   { value: current_value },
              trigger: html_opts
            )
            render_combobox(attribute, input_id: html_opts[:id], opts: dropdown_opts, err: err) do
              Components::Combobox::Dropdown.new(@template).render(
                options:    choices,
                value:      current_value,
                labelledby: Field.label_id(html_opts[:id])
              )
            end
          end

          def build_dropdown_choices(choices, include_blank:, prompt:)
            return choices unless include_blank || prompt

            choices = choices.dup
            choices.unshift([include_blank.is_a?(String) ? include_blank : "", ""]) if include_blank
            choices.unshift(blank_prompt_choice(prompt)) if prompt
            choices
          end

          def blank_prompt_choice(prompt)
            label = prompt.is_a?(String) ? prompt : I18n.t("helpers.select.prompt", default: "Please select")
            [label, "", { disabled: true }]
          end
        end
      end
    end
  end
end
