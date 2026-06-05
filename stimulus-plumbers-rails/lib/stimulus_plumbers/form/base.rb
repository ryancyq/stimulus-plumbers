# frozen_string_literal: true

module StimulusPlumbers
  module Form
    class Base
      OPTIONS = %i[label hint error required layout floating].freeze

      attr_reader(*OPTIONS)

      def initialize(
        template,
        label: nil,
        hint: nil,
        error: nil,
        required: false,
        layout: :stacked,
        floating: nil,
        **kwargs
      )
        @template = template
        @label    = label
        @hint     = hint
        @error    = error
        @required = required
        @layout   = layout.to_sym
        @floating = floating
        @kwargs   = kwargs
      end

      def theme
        StimulusPlumbers.config.theme.current
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

      def render_hint(input_id)
        Fields::Hint.new(@template).render(text: @hint, id: hint_id(input_id)) if @hint.present?
      end

      def render_errors(object, attribute, input_id)
        errs = build_errors(object, attribute)
        return if errs.none?

        @template.safe_join(
          errs.map.with_index do |message, i|
            Fields::Error.new(@template).render(message: message, id: build_error_ids(object, attribute, input_id)[i])
          end
        )
      end

      private

      def build_errors(object, attribute)
        if error
          Array(error)
        elsif object.respond_to?(:errors)
          object.errors[attribute]
        else
          []
        end
      end

      def build_aria(object, attribute, input_id)
        aria = {}
        aria[:describedby] = described_by(object, attribute, input_id)
        aria[:invalid]     = "true" if error?(object, attribute)
        aria[:required]    = "true" if @required
        aria.compact
      end

      def build_html_options(input_id, aria)
        attrs = { id: input_id, aria: aria }
        attrs[:required] = true if @required
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
    end
  end
end
