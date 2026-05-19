# frozen_string_literal: true

module StimulusPlumbers
  module Form
    class Field
      attr_reader :label, :required, :layout

      def initialize(
        template,
        label: nil,
        hint: nil,
        error: nil,
        required: false,
        hide_label: false,
        layout: :stacked,
        **kwargs
      )
        @template       = template
        @label          = label
        @hint           = hint
        @error_override = error
        @required       = required
        @hide_label     = hide_label
        @layout         = layout.to_sym
        @kwargs         = kwargs
      end

      def label_hidden?
        @hide_label
      end

      def error?(object, attribute)
        build_errors(object, attribute).any?
      end

      def described_by(object, attribute, input_id)
        ids = []
        ids << hint_id(input_id) if @hint.present?
        ids.concat(build_error_ids(object, attribute, input_id))
        ids.join(" ").presence
      end

      def render(object, attribute, input_id:)
        @label ||= attribute.to_s.humanize
        error          = error?(object, attribute)
        aria           = build_aria(object, attribute, input_id)
        generated_opts = build_html_options(input_id, aria)
        field_html     = yield(generated_opts, @kwargs, error)
        Fields::Group.new(@template).render(layout: @layout, error: error) do
          @template.safe_join(
            [
              field_label(input_id),
              field_html,
              render_hint(input_id),
              render_errors(object, attribute, input_id)
            ]
          )
        end
      end

      def render_hint(input_id)
        return nil unless @hint.present?

        Fields::Hint.new(@template).render(text: @hint, id: hint_id(input_id))
      end

      def render_errors(object, attribute, input_id)
        errs = build_errors(object, attribute)
        return nil if errs.none?

        @template.safe_join(
          errs.map.with_index do |message, i|
            Fields::Error.new(@template).render(message: message, id: build_error_ids(object, attribute, input_id)[i])
          end
        )
      end

      private

      def build_errors(object, attribute)
        if @error_override
          Array(@error_override)
        elsif object.respond_to?(:errors)
          object.errors[attribute]
        else
          []
        end
      end

      def build_aria(object, attribute, input_id)
        aria = {}
        db = described_by(object, attribute, input_id)
        aria[:describedby] = db     if db
        aria[:invalid]     = "true" if error?(object, attribute)
        aria[:required]    = "true" if @required
        aria
      end

      def build_html_options(input_id, aria)
        attrs = { id: input_id }
        attrs[:required] = true if @required
        attrs[:aria] = aria
        attrs
      end

      def hint_id(input_id)
        [input_id, "hint"].compact.join("_")
      end

      def error_id(input_id)
        [input_id, "error"].compact.join("_")
      end

      def build_error_ids(object, attribute, input_id)
        errs = build_errors(object, attribute)
        return [] if errs.none?
        return [error_id(input_id)] if errs.one?

        errs.each_index.map { |i| [error_id(input_id), i + 1].compact.join("_") }
      end

      def field_label(input_id)
        Fields::Label.new(@template).render(
          text:     @label,
          for_id:   input_id,
          required: @required,
          hidden:   @hide_label
        )
      end
    end
  end
end
