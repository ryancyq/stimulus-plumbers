# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        # A range is a track and a thumb, not a text box, so it takes none of the text input's
        # chrome. With `format:` it grows a readout driven by the progress controller.
        module Range
          include Components::Progress::Shared

          def range_field(attribute, **options)
            super(attribute, merge_html_options(theme.resolve(:form_field_input_range), options.except(:floating)))
          end

          private

          # `floating:` is dropped — a label can't sit inside a slider.
          def render_range_input(attribute, input_attrs, opts, _error, format: nil, min: 0, max: 100, **kwargs)
            validate_format!(format)
            current = clamp(numeric(object.public_send(attribute)), min, max)
            input   = range_input(attribute, current, min, max, format, input_attrs, opts, kwargs.except(:floating))
            return input if format.nil?

            range_container(input, current, min, max, format)
          end

          # No readout to contain, so the input hosts the controller itself.
          def range_input(attribute, current, min, max, format, input_attrs, opts, kwargs)
            input_stimulus_attrs =
              format.nil? ? range_stimulus_attrs(current, min, max, format) : { data: { "progress-target": "input" } }
            html_options = merge_html_options(
              theme.resolve(:form_field_input_range),
              opts,
              input_attrs,
              kwargs,
              input_stimulus_attrs,
              # The input carries the track gradient, so the fill percentage lands here, not on
              # the container. Server-rendered so the fill is right before the controller connects.
              { min: min, max: max, style: "--sp-progress-percent: #{integral(percent(current, min, max).round(2))}" }
            )
            @template.range_field(@object_name, attribute, objectify_options(html_options))
          end

          # A Stimulus target must be a descendant of its controller element, so a readout
          # forces a container local to the input row.
          def range_container(input, current, min, max, format)
            html_options = merge_html_options(
              theme.resolve(:form_field_input_range_container),
              range_stimulus_attrs(current, min, max, format)
            )
            body = @template.safe_join([input, range_value(format, current, min, max)])
            @template.content_tag(:div, body, **html_options)
          end

          # aria-hidden: the native input already announces its own value.
          def range_value(format, current, min, max)
            @template.content_tag(
              :span,
              value_text(format, current, min, max),
              **merge_html_options(
                theme.resolve(:form_field_input_range_value),
                { data: { "progress-target": "value" }, aria: { hidden: true } }
              )
            )
          end

          def range_stimulus_attrs(current, min, max, format)
            progress_stimulus_attrs(
              value:   current,
              min:     min,
              max:     max,
              variant: "range",
              action:  "input->progress#refresh",
              **(format.nil? ? {} : { "progress-format-value": format })
            )
          end
        end
      end
    end
  end
end
