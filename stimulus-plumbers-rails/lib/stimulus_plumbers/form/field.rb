# frozen_string_literal: true

require_relative "base"
require_relative "../themes/schema/form/floating/ranges"

module StimulusPlumbers
  module Form
    class Field < Base
      TYPES = %i[
        text email number url tel color month week range datetime_local
        text_area file password date time select search code credit_card
      ].freeze
      COLLECTION_TYPES = %i[radio check_box collection_select grouped_collection_select].freeze
      OPTIONS          = (Base::OPTIONS + %i[hide_label]).freeze

      # :aria uses aria-labelledby because non-labelable components cannot use `<label for>`.
      LABEL_MODES = %i[native aria].freeze

      attr_reader :hide_label, :label_mode

      class << self
        def label_id(input_id)
          [input_id, "label"].compact.join("_")
        end

        def validate_label_mode!(mode)
          return mode if LABEL_MODES.include?(mode)

          raise ArgumentError, "unknown label_mode: #{mode.inspect} (expected one of #{LABEL_MODES.join(", ")})"
        end
      end

      def initialize(template, hide_label: false, label_mode: :native, **kwargs)
        super(template, **kwargs)
        @hide_label = hide_label
        @label_mode = self.class.validate_label_mode!(label_mode)
      end

      def label_hidden?
        @hide_label
      end

      def native_label?
        @label_mode == :native
      end

      def render(object, attribute, input_id:, &block)
        @label ||= attribute.to_s.humanize
        case native_label? ? @floating : nil
        when *StimulusPlumbers::Themes::Schema::Form::Floating::Ranges::TYPE
          render_floating_field(object, attribute, input_id, &block)
        else
          render_default_field(object, attribute, input_id, &block)
        end
      end

      private

      def build_aria(object, attribute, input_id)
        return super if native_label?

        { describedby: described_by(object, attribute, input_id), labelledby: self.class.label_id(input_id) }.compact
      end

      def build_html_options(input_id, aria)
        return super if native_label?

        { id: input_id, aria: aria }
      end

      def render_default_field(object, attribute, input_id, &block)
        error_override = error?(object, attribute)
        aria           = build_aria(object, attribute, input_id)
        field_opts = build_html_options(input_id, aria)
        field_html = @template.capture(field_opts, @kwargs, error_override, &block)
        Fields::Group.new(@template).render(layout: @layout, error: error_override) do
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

      # hide_label is visual only; :aria fields cannot be required.
      def field_label(input_id)
        Fields::Label.new(@template).render(
          text:     @label,
          for_id:   (input_id if native_label?),
          id:       self.class.label_id(input_id),
          required: native_label? && @required,
          hidden:   @hide_label,
          tag:      native_label? ? :label : :span
        )
      end

      def render_floating_field(object, attribute, input_id, &block)
        error_override = error?(object, attribute)
        aria           = build_aria(object, attribute, input_id)
        field_opts     = build_html_options(input_id, aria).merge(placeholder: " ")
        Fields::Group.new(@template).render(layout: @layout, error: error_override) do
          @template.safe_join(
            [
              floating_field_label(input_id, error: error_override) do
                @template.capture(field_opts, @kwargs, error_override, &block)
              end,
              render_hint(input_id),
              render_errors(object, attribute, input_id)
            ]
          )
        end
      end

      def floating_field_label(input_id, error:, &block)
        Fields::Label::Floating.new(@template).render(
          text:     @label,
          for_id:   input_id,
          id:       self.class.label_id(input_id),
          floating: @floating,
          required: @required,
          error:    error,
          &block
        )
      end
    end
  end
end
