# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module CreditCard
          STIMULUS_CONTROLLER  = "input-formatter"
          STIMULUS_ACTION      = [
            "input->#{STIMULUS_CONTROLLER}#onInput",
            "focus->#{STIMULUS_CONTROLLER}#onFocus",
            "blur->#{STIMULUS_CONTROLLER}#onBlur"
          ].join(" ").freeze
          DEFAULT_GROUPS       = [4, 4, 4, 4].freeze
          DEFAULT_AUTOCOMPLETE = "cc-number"
          DEFAULT_INPUTMODE    = "numeric"
          DEFAULT_SEPARATOR    = nil

          private

          def render_credit_card_input(
            attribute,
            input_attrs,
            opts,
            error,
            groups: DEFAULT_GROUPS,
            separator: DEFAULT_SEPARATOR,
            floating: nil,
            **kwargs
          )
            raise ArgumentError, "floating labels are not supported for credit card fields" if floating.present?

            normalized_groups = groups.presence || DEFAULT_GROUPS
            validate_credit_card_groups!(normalized_groups)
            config = {
              error:        error,
              groups:       normalized_groups,
              maxlength:    normalized_groups.sum + normalized_groups.length - 1,
              separator:    separator,
              autocomplete: kwargs.delete(:autocomplete) || DEFAULT_AUTOCOMPLETE,
              inputmode:    kwargs.delete(:inputmode) || DEFAULT_INPUTMODE,
              kwargs:       kwargs
            }
            render_credit_card_field(attribute, input_attrs, opts, config)
          end

          def render_credit_card_field(attribute, input_attrs, opts, config)
            overlay_attrs = merge_html_options(
              theme.resolve(:form_field_input_credit_card_overlay, error: config[:error]),
              opts,
              input_attrs
            )
            container_attrs = merge_html_options(
              theme.resolve(:form_field_input_credit_card, error: config[:error]),
              credit_card_options(config)
            )
            @template.content_tag(:div, **container_attrs) do
              @template.safe_join(
                [render_credit_card_cells(config), credit_card_input(attribute, overlay_attrs, config)]
              )
            end
          end

          def credit_card_options(config)
            {
              data: {
                controller:                   STIMULUS_CONTROLLER,
                input_formatter_format_value: "creditCard",
                input_formatter_groups_value: config[:groups]
              }
            }
          end

          def credit_card_input(attribute, overlay_attrs, config)
            html_options = merge_html_options(
              overlay_attrs,
              config[:kwargs],
              {
                maxlength:    config[:maxlength],
                autocomplete: config[:autocomplete],
                inputmode:    config[:inputmode],
                data:         { input_formatter_target: "input", action: STIMULUS_ACTION }
              }
            )
            @template.text_field(@object_name, attribute, objectify_options(html_options))
          end

          def render_credit_card_cells(config)
            @template.content_tag(:div, **merge_html_options(theme.resolve(:form_field_input_credit_card_cells))) do
              @template.safe_join(credit_card_cells(config))
            end
          end

          def credit_card_cells(config)
            config[:groups].each_index.flat_map do |index|
              cell = render_credit_card_cell(config)
              index.zero? || config[:separator].blank? ? [cell] : [render_credit_card_separator(config), cell]
            end
          end

          def render_credit_card_cell(config)
            cell_attrs = merge_html_options(
              theme.resolve(:form_field_input_credit_card_cell, error: config[:error]),
              { data: { input_formatter_target: "cell" } }
            )
            @template.content_tag(:span, nil, **cell_attrs)
          end

          def render_credit_card_separator(config)
            separator_attrs = merge_html_options(
              theme.resolve(:form_field_input_credit_card_separator),
              { aria: { hidden: true } }
            )
            @template.content_tag(:span, config[:separator], **separator_attrs)
          end

          def validate_credit_card_groups!(groups)
            return if groups.is_a?(Array) && groups.all? { |group| group.is_a?(Integer) && group.positive? }

            raise ArgumentError, "groups must be an array of positive integers"
          end
        end
      end
    end
  end
end
