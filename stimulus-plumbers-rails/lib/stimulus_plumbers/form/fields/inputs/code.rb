# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Code
          STIMULUS_CONTROLLER  = "input-formatter"
          STIMULUS_ACTION      = [
            "input->#{STIMULUS_CONTROLLER}#onInput",
            "focus->#{STIMULUS_CONTROLLER}#onFocus",
            "blur->#{STIMULUS_CONTROLLER}#onBlur"
          ].join(" ").freeze
          DEFAULT_CHARSET      = :digits
          DEFAULT_AUTOCOMPLETE = "one-time-code"
          DEFAULT_SEPARATOR    = nil

          private

          def render_code_input(
            attribute,
            html_opts,
            opts,
            error,
            length: nil,
            charset: DEFAULT_CHARSET,
            groups: [],
            separator: DEFAULT_SEPARATOR,
            floating: nil,
            **kwargs
          )
            raise ArgumentError, "floating labels are not supported for code fields" if floating.present?

            validate_code_options!(length, groups)
            config = {
              error:        error,
              length:       length,
              charset:      charset,
              groups:       groups,
              separator:    separator,
              autocomplete: kwargs.delete(:autocomplete) || DEFAULT_AUTOCOMPLETE,
              inputmode:    kwargs.delete(:inputmode) || (charset.to_sym == DEFAULT_CHARSET ? "numeric" : nil),
              kwargs:       kwargs
            }
            render_code_field(attribute, html_opts, opts, config)
          end

          def render_code_field(attribute, html_opts, opts, config)
            overlay_options = merge_html_options(
              theme.resolve(:form_field_input_code_overlay, error: config[:error]),
              opts,
              html_opts
            )
            wrapper_options = merge_html_options(
              theme.resolve(:form_field_input_code, error: config[:error]),
              code_options(config)
            )
            @template.content_tag(:div, **wrapper_options) do
              @template.safe_join(
                [render_code_cells(config), code_input(attribute, overlay_options, config)]
              )
            end
          end

          def code_options(config)
            {
              data: {
                controller:                    STIMULUS_CONTROLLER,
                input_formatter_format_value:  "code",
                input_formatter_options_value: { charset: config[:charset].to_s, length: config[:length] },
                input_formatter_groups_value:  code_groups_value(config)
              }
            }
          end

          # Server-rendered separators already mark the group breaks. Passing groups as well
          # would stamp data-group-end and lay the themed gap on top of the separator.
          def code_groups_value(config)
            return if config[:separator].present?

            config[:groups].presence
          end

          def code_input(attribute, html_opts, config)
            input_options = merge_html_options(
              html_opts,
              config[:kwargs],
              {
                maxlength:    config[:length],
                autocomplete: config[:autocomplete],
                inputmode:    config[:inputmode],
                data:         { input_formatter_target: "input", action: STIMULUS_ACTION }
              }
            )
            @template.text_field(@object_name, attribute, objectify_options(input_options))
          end

          def render_code_cells(config)
            @template.content_tag(:div, **merge_html_options(theme.resolve(:form_field_input_code_cells))) do
              @template.safe_join(code_cells(config))
            end
          end

          def code_cells(config)
            groups = config[:groups].presence || [config[:length]]
            groups.flat_map.with_index do |width, index|
              cells = Array.new(width) { render_code_cell(config) }
              index.zero? || config[:separator].blank? ? cells : [render_code_separator(config), *cells]
            end
          end

          def render_code_cell(config)
            cell_options = merge_html_options(
              theme.resolve(:form_field_input_code_cell, error: config[:error]),
              { data: { input_formatter_target: "cell" } }
            )
            @template.content_tag(:span, nil, **cell_options)
          end

          def render_code_separator(config)
            separator_options = merge_html_options(
              theme.resolve(:form_field_input_code_separator),
              { aria: { hidden: true } }
            )
            @template.content_tag(:span, config[:separator], **separator_options)
          end

          def validate_code_options!(length, groups)
            raise ArgumentError, "length must be a positive integer" unless positive_integer?(length)
            return if groups.blank?

            raise ArgumentError, "groups must be an array of positive integers" unless valid_groups?(groups)
            raise ArgumentError, "groups must add up to length" unless groups.sum == length
          end

          def valid_groups?(groups)
            groups.is_a?(Array) && groups.all? { |group| positive_integer?(group) }
          end

          def positive_integer?(value)
            value.is_a?(Integer) && value.positive?
          end
        end
      end
    end
  end
end
