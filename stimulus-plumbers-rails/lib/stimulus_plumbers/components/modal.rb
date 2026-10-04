# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Modal < Plumber::Base
      STIMULUS_CONTROLLER = "modal"
      CLOSED_BY = %i[any closerequest none].freeze
      KINDS = %i[dialog alertdialog].freeze

      def render(id:, title: nil, aria_label: nil, size: :md, closed_by: :closerequest, kind: :dialog, **html_options)
        options = modal_options(id, title, aria_label, size, closed_by, kind)
        slots = Modal::Slots.new(template, modal_id: options[:id])
        yield slots if block_given?

        template.content_tag(:div, **wrapper_attrs(html_options)) do
          template.safe_join([slots.resolve(:trigger), render_dialog(slots, options)].compact)
        end
      end

      private

      def modal_options(id, title, aria_label, size, closed_by, kind)
        title = title.presence
        aria_label = aria_label.presence
        validate_name!(title, aria_label)

        {
          id:         validate_id!(id),
          title:      title,
          aria_label: aria_label,
          size:       size,
          closed_by:  validate_choice!(closed_by, CLOSED_BY, :closed_by),
          kind:       validate_choice!(kind, KINDS, :kind)
        }
      end

      def wrapper_attrs(html_options)
        merge_html_options(
          theme.resolve(:modal_wrapper),
          html_options,
          { data: { controller: STIMULUS_CONTROLLER } }
        )
      end

      def render_dialog(slots, options)
        template.content_tag(:dialog, **dialog_attrs(options)) do
          template.safe_join([render_header(slots, options), render_region(slots, :body), render_region(slots, :footer)].compact)
        end
      end

      def dialog_attrs(options)
        attrs = merge_html_options(
          theme.resolve(:modal, size: options[:size]),
          theme.resolve(:modal_backdrop),
          {
            id:       options[:id],
            closedby: options[:closed_by].to_s,
            data:     { "modal-target": "dialog" },
            aria:     dialog_name(options)
          }
        )
        attrs[:role] = "alertdialog" if options[:kind] == :alertdialog
        attrs
      end

      def dialog_name(options)
        return { labelledby: title_id(options[:id]) } if options[:title]

        { label: options[:aria_label] }
      end

      def render_header(slots, options)
        extra = slots.resolve(:header)
        return unless options[:title] || extra

        template.content_tag(:header, **merge_html_options(theme.resolve(:modal_header))) do
          template.safe_join([render_title(options), extra].compact)
        end
      end

      def render_title(options)
        return unless options[:title]

        template.content_tag(
          :h2, options[:title], id: title_id(options[:id]), **merge_html_options(theme.resolve(:modal_title))
        )
      end

      def render_region(slots, name)
        content = slots.resolve(name)
        return unless content

        tag = name == :footer ? :footer : :div
        template.content_tag(tag, content, **merge_html_options(theme.resolve(:"modal_#{name}")))
      end

      def title_id(id)
        "#{id}-title"
      end

      def validate_id!(id)
        value = id.to_s
        raise ArgumentError, "modal id must be a nonblank stable id" if value.blank?

        value
      end

      def validate_name!(title, aria_label)
        return if title || aria_label

        raise ArgumentError, "modal requires title: or aria_label:"
      end

      def validate_choice!(value, choices, name)
        normalized = value.to_sym if value.respond_to?(:to_sym)
        return normalized if choices.include?(normalized)

        raise ArgumentError, "modal #{name} must be one of: #{choices.join(", ")}"
      end
    end
  end
end
