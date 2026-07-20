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
            html_options = merge_html_options(theme.resolve(:form_field_input), options, data)
            render_input_group(
              trailing: clearable ? method(:clear_button) : nil,
              error:    false,
              **merge_html_options(
                theme.resolve(:form_field_input_clearable),
                clearable ? { data: { controller: "input-clearable" } } : {}
              )
            ) { super(attribute, html_options) }
          end

          private

          def render_combobox_typeahead(
            attribute,
            html_opts,
            opts,
            error,
            floating: nil,
            url: nil,
            clearable: false,
            choices: [],
            **kwargs
          )
            current_value = object.respond_to?(attribute) ? object.public_send(attribute) : nil
            input_id      = html_opts[:id]
            labelledby    = Field.label_id(input_id)
            combobox_opts = {
              input:   { value: current_value },
              trigger: {
                data: clearable ? { input_clearable_target: "input" } : {},
                aria: html_opts[:aria]
              },
              **opts
            }

            render_input_group(
              trailing: clearable ? method(:clear_button) : nil,
              error:    error,
              floating: floating,
              **merge_html_options(theme.resolve(:form_field_input_clearable), { data: { controller: "input-clearable" } })
            ) do
              build_combobox_typeahead(
                attribute,
                combobox_opts,
                input_id: input_id,
                floating: floating,
                error:    error,
                **kwargs
              ) do |c|
                c.typeahead(options: choices, value: current_value, labelledby: labelledby, url: url)
              end
            end
          end

          def build_combobox_typeahead(attribute, opts, input_id:, floating:, error:, **kwargs, &block)
            render_combobox(
              attribute,
              input_id: input_id,
              opts:     opts,
              error:    error,
              floating: floating,
              **kwargs,
              &block
            )
          end

          def clear_button
            build_clear_button do
              Components::Icon.new(@template).render(
                "close",
                size: :sm,
                aria: { hidden: "true" },
                **theme.resolve(:button_icon)
              )
            end
          end

          def build_clear_button(&block)
            @template.content_tag(
              :button,
              **merge_html_options(
                theme.resolve(:form_field_input_button_clear),
                {
                  type:   "button",
                  hidden: true,
                  aria:   { label: I18n.t("stimulus_plumbers.form.search.clear", default: "Clear search") },
                  data:   { input_clearable_target: "clear", action: "click->input-clearable#clear" }
                }
              )
            ) { @template.capture(&block) }
          end
        end
      end
    end
  end
end
