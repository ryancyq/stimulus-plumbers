# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module CreditCard
          DEFAULT_GROUPS = [4, 4, 4, 4].freeze

          private

          def render_credit_card_input(attribute, html_opts, opts, error, groups: DEFAULT_GROUPS, floating: nil, **kwargs)
            raise ArgumentError, "floating labels are not supported for credit card fields" if floating.present?

            normalized_groups = groups.presence || DEFAULT_GROUPS
            inputmode = kwargs.delete(:inputmode) || "numeric"
            autocomplete = kwargs.delete(:autocomplete) || "cc-number"
            validate_credit_card_groups!(normalized_groups)
            length = normalized_groups.sum
            config = { error: error, groups: normalized_groups, length: length,
                       autocomplete: autocomplete, inputmode: inputmode, kwargs: kwargs
}
            render_credit_card_field(attribute, html_opts, opts, config)
          end

          def render_credit_card_field(attribute, html_opts, opts, config)
            @template.content_tag(:div, **credit_card_wrapper_options(config)) do
              @template.safe_join(
                [render_credit_card_cells(config), credit_card_input(attribute, html_opts, opts, config)]
              )
            end
          end

          def credit_card_wrapper_options(config)
            merge_html_options(
              theme.resolve(:form_field_input_credit_card, error: config[:error]),
              { data: {
                controller:                   "input-formatter",
                input_formatter_format_value: "creditCard",
                input_formatter_groups_value: config[:groups]
              }
}
            )
          end

          def credit_card_input(attribute, html_opts, opts, config)
            input_options = merge_html_options(
              theme.resolve(:form_field_input_credit_card_overlay, error: config[:error]),
              opts,
              html_opts,
              config[:kwargs],
              { maxlength: config[:length], autocomplete: config[:autocomplete], inputmode: config[:inputmode],
                data: { input_formatter_target: "input", action: formatter_actions }
}
            )
            @template.text_field(@object_name, attribute, objectify_options(input_options))
          end

          def render_credit_card_cells(config)
            cells = config[:groups].each_index.flat_map do |index|
              index.zero? ? [render_credit_card_cell(config)] : [render_credit_card_separator, render_credit_card_cell(config)]
            end

            @template.content_tag(:div, **merge_html_options(theme.resolve(:form_field_input_credit_card_cells))) do
              @template.safe_join(cells)
            end
          end

          def render_credit_card_cell(config)
            cell_options = merge_html_options(
              theme.resolve(:form_field_input_credit_card_cell, error: config[:error]),
              { data: { input_formatter_target: "cell" } }
            )
            @template.content_tag(:span, nil, **cell_options)
          end

          def render_credit_card_separator
            separator_options = merge_html_options(
              theme.resolve(:form_field_input_credit_card_separator),
              { aria: { hidden: true } }
            )
            @template.content_tag(:span, "-", **separator_options)
          end

          def validate_credit_card_groups!(groups)
            return if groups.is_a?(Array) && groups.all? { |group| group.is_a?(Integer) && group.positive? }

            raise ArgumentError, "groups must be an array of positive integers"
          end

          def formatter_actions
            "input->input-formatter#onInput focus->input-formatter#onFocus blur->input-formatter#onBlur"
          end
        end
      end
    end
  end
end
