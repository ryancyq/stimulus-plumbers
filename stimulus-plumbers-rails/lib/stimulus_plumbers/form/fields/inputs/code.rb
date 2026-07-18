# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Code
          private

          def render_code_input(attribute, html_opts, opts, error, length:, charset: :digits, groups: [], **kwargs)
            floating = kwargs.delete(:floating)
            raise ArgumentError, "floating labels are not supported for code fields" if floating.present?

            validate_code_options!(length, groups)
            inputmode = kwargs.delete(:inputmode) || (charset.to_sym == :digits ? "numeric" : nil)
            autocomplete = kwargs.delete(:autocomplete) || "one-time-code"
            config = { error: error, length: length, charset: charset, groups: groups,
                       autocomplete: autocomplete, inputmode: inputmode, kwargs: kwargs
}
            render_code_field(attribute, html_opts, opts, config)
          end

          def render_code_field(attribute, html_opts, opts, config)
            @template.content_tag(:div, **code_wrapper_options(config)) do
              @template.safe_join(
                [render_code_cells(config), code_input(attribute, html_opts, opts, config)]
              )
            end
          end

          def code_wrapper_options(config)
            merge_html_options(
              theme.resolve(:form_field_input_code, error: config[:error]),
              { data: {
                controller:                    "input-formatter",
                input_formatter_format_value:  "code",
                input_formatter_options_value: { charset: config[:charset].to_s, length: config[:length] }.to_json,
                input_formatter_groups_value:  config[:groups].presence
              }
}
            )
          end

          def code_input(attribute, html_opts, opts, config)
            input_options = merge_html_options(
              theme.resolve(:form_field_input_code_overlay, error: config[:error]),
              opts,
              html_opts,
              config[:kwargs],
              { maxlength: config[:length], autocomplete: config[:autocomplete], inputmode: config[:inputmode],
                data: { input_formatter_target: "input", action: formatter_actions }
}
            )
            @template.text_field(@object_name, attribute, objectify_options(input_options))
          end

          def render_code_cells(config)
            count = config[:groups].present? ? config[:groups].sum : config[:length]
            cell_options = merge_html_options(
              theme.resolve(:form_field_input_code_cell, error: config[:error]),
              { data: { input_formatter_target: "cell" } }
            )
            @template.content_tag(:div, **merge_html_options(theme.resolve(:form_field_input_code_cells))) do
              @template.safe_join(Array.new(count) { @template.content_tag(:span, nil, **cell_options) })
            end
          end

          def validate_code_options!(length, groups)
            raise ArgumentError, "length must be a positive integer" unless positive_integer?(length)
            return if groups.blank?

            raise ArgumentError, "groups must be an array of positive integers" unless valid_groups?(groups)
            raise ArgumentError, "groups must add up to length" unless groups.sum == length
          end

          def valid_groups?(groups) = groups.is_a?(Array) && groups.all? { |group| positive_integer?(group) }
          def positive_integer?(value) = value.is_a?(Integer) && value.positive?

          def formatter_actions
            "input->input-formatter#onInput focus->input-formatter#onFocus blur->input-formatter#onBlur"
          end
        end
      end
    end
  end
end
