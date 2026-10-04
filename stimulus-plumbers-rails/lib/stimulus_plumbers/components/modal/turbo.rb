# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Modal
      class Turbo < Plumber::Base
        STIMULUS_CONTROLLERS = "modal modal-turbo"

        def render(id:, size: :md, closed_by: :closerequest, close_on_success: true, aria_label: nil, **html_options)
          options = {
            id:               validate_id!(id),
            size:             size,
            closed_by:        validate_choice!(closed_by, Modal::CLOSED_BY, :closed_by),
            close_on_success: close_on_success,
            aria_label:       aria_label.presence
          }

          template.content_tag(:div, **wrapper_attrs(html_options, options)) do
            template.content_tag(:dialog, **dialog_attrs(options)) do
              render_frame(options[:id])
            end
          end
        end

        private

        def wrapper_attrs(html_options, options)
          merge_html_options(
            theme.resolve(:modal_wrapper),
            html_options,
            {
              data: {
                controller:                           STIMULUS_CONTROLLERS,
                action:                               "modal:closed->modal-turbo#onClosed",
                "modal-turbo-close-on-success-value": options[:close_on_success]
              }
            }
          )
        end

        def dialog_attrs(options)
          merge_html_options(
            theme.resolve(:modal, size: options[:size]),
            theme.resolve(:modal_backdrop),
            {
              closedby: options[:closed_by].to_s,
              data:     { "modal-target": "dialog" },
              aria:     dialog_name(options)
            }
          )
        end

        def dialog_name(options)
          return { label: options[:aria_label] } if options[:aria_label]

          { labelledby: "#{options[:id]}-title" }
        end

        def render_frame(id)
          attrs = merge_html_options(
            theme.resolve(:modal_turbo),
            {
              id:   id,
              data: {
                "modal-turbo-target": "frame",
                action:               "turbo:before-fetch-request->modal-turbo#onBeforeFetchRequest " \
                                      "turbo:frame-render->modal-turbo#onFrameRender " \
                                      "turbo:submit-end->modal-turbo#onSubmitEnd"
              }
            }
          )
          template.content_tag("turbo-frame", nil, **attrs)
        end

        def validate_id!(id)
          value = id.to_s
          raise ArgumentError, "modal id must be a nonblank stable id" if value.blank?

          value
        end

        def validate_choice!(value, choices, name)
          normalized = value.to_sym if value.respond_to?(:to_sym)
          return normalized if choices.include?(normalized)

          raise ArgumentError, "modal #{name} must be one of: #{choices.join(", ")}"
        end
      end
    end
  end
end
