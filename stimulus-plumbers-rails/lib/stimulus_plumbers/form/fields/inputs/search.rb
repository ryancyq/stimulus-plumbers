# frozen_string_literal: true

require_relative "combobox"

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Search
          include Combobox

          def search_field(attribute, options = {})
            clearable = options.delete(:clearable) { false }
            clearable_stimulus_attrs = clearable ? { data: { input_clearable_target: "input" } } : {}
            html_options = merge_html_options(theme.resolve(:form_field_input), options, clearable_stimulus_attrs)
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
            input_attrs,
            opts,
            error,
            floating: nil,
            clearable: false,
            choices: [],
            value_policy: :freeform,
            **kwargs
          )
            render_combobox(
              attribute,
              component:    Components::Combobox::Typeahead,
              input_attrs:  input_attrs,
              opts:         clearable ? merge_html_options(opts, { data: { controller: "input-clearable" } }) : opts,
              error:        error,
              floating:     floating,
              trigger:      clearable ? { data: { input_clearable_target: "input" } } : {},
              trailing:     clearable ? method(:clear_button) : nil,
              options:      choices,
              value:        object.respond_to?(attribute) ? object.public_send(attribute) : nil,
              value_policy: value_policy,
              **kwargs
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
