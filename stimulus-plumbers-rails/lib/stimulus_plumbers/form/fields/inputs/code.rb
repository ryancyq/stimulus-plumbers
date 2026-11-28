# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Code
          FORMATTER_CONTROLLER = "input-formatter"
          CODE_CONTROLLER      = "input-code"
          STIMULUS_ACTION      = [
            "input->#{FORMATTER_CONTROLLER}#onInput",
            "form:reset->#{FORMATTER_CONTROLLER}#onFormReset",
            *%w[focus blur select selectionchange keyup].map { |event| "#{event}->#{CODE_CONTROLLER}#draw" }
          ].join(" ").freeze
          DEFAULT_CHARSET      = :digits
          DEFAULT_AUTOCOMPLETE = "one-time-code"
          DEFAULT_SEPARATOR    = nil

          private

          def render_code_input(
            attribute,
            input_attrs,
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
            render_code_field(attribute, input_attrs, opts, config)
          end

          def render_code_field(attribute, input_attrs, opts, config)
            overlay_attrs = merge_html_options(
              theme.resolve(:form_field_input_code_overlay, error: config[:error]),
              opts,
              input_attrs
            )
            container_attrs = merge_html_options(
              theme.resolve(:form_field_input_code, error: config[:error]),
              code_stimulus_attrs(config)
            )
            @template.content_tag(:div, **container_attrs) do
              @template.safe_join(
                [render_code_cells(config), code_input(attribute, overlay_attrs, config)]
              )
            end
          end

          def code_stimulus_attrs(config)
            {
              data: {
                controller:                    "#{FORMATTER_CONTROLLER} #{CODE_CONTROLLER}",
                input_formatter_format_value:  "code",
                input_formatter_options_value: { charset: config[:charset].to_s, length: config[:length] },
                action:                        "#{FORMATTER_CONTROLLER}:formatted->#{CODE_CONTROLLER}#draw"
              }
            }
          end

          def code_input(attribute, overlay_attrs, config)
            html_options = merge_html_options(
              overlay_attrs,
              config[:kwargs],
              {
                autocomplete: config[:autocomplete],
                inputmode:    config[:inputmode],
                data:         { input_formatter_target: "input", input_code_target: "input", action: STIMULUS_ACTION }
              }
            )
            @template.text_field(@object_name, attribute, objectify_options(html_options))
          end

          def render_code_cells(config)
            @template.content_tag(:div, **merge_html_options(theme.resolve(:form_field_input_code_cells))) do
              @template.safe_join(code_cells(config))
            end
          end

          def code_cells(config)
            groups = config[:groups].presence || [config[:length]]
            groups.flat_map.with_index do |width, index|
              cells = Array.new(width) do |position|
                render_code_cell(config, group_end: code_group_end?(config, groups, index, position))
              end
              index.zero? || config[:separator].blank? ? cells : [render_code_separator(config), *cells]
            end
          end

          # Without a separator, the last cell of each group but the final one marks the gap.
          def code_group_end?(config, groups, index, position)
            config[:separator].blank? && index < groups.length - 1 && position == groups[index] - 1
          end

          def render_code_cell(config, group_end:)
            cell_attrs = merge_html_options(
              theme.resolve(:form_field_input_code_cell, error: config[:error]),
              { data: { input_code_target: "cell", group_end: (true if group_end) } }
            )
            @template.content_tag(:span, nil, **cell_attrs)
          end

          def render_code_separator(config)
            separator_attrs = merge_html_options(
              theme.resolve(:form_field_input_code_separator),
              { aria: { hidden: true } }
            )
            @template.content_tag(:span, config[:separator], **separator_attrs)
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
