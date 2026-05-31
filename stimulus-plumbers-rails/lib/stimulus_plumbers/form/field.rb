# frozen_string_literal: true

require_relative "base"

module StimulusPlumbers
  module Form
    class Field < Base
      TYPES = %i[
        text email number url tel color month week range datetime_local
        text_area file password date time select search
      ].freeze
      COLLECTION_TYPES = %i[radio check_box collection_select grouped_collection_select].freeze
      OPTIONS = (Base::OPTIONS + %i[hide_label]).freeze

      attr_reader :hide_label

      def self.label_id(input_id)
        [input_id, "label"].compact.join("_")
      end

      def initialize(template, hide_label: false, **kwargs)
        super(template, **kwargs)
        @hide_label = hide_label
      end

      def label_hidden?
        @hide_label
      end

      def render(object, attribute, input_id:, &block)
        @label ||= attribute.to_s.humanize
        error_override = error?(object, attribute)
        aria           = build_aria(object, attribute, input_id)
        generated_opts = build_html_options(input_id, aria)
        field_html     = @template.capture(generated_opts, @kwargs, error_override, &block)
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

      private

      def field_label(input_id)
        Fields::Label.new(@template).render(
          text:     @label,
          for_id:   input_id,
          id:       self.class.label_id(input_id),
          required: @required,
          hidden:   @hide_label
        )
      end
    end
  end
end
