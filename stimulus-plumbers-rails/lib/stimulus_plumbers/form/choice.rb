# frozen_string_literal: true

require_relative "base"

module StimulusPlumbers
  module Form
    class Choice < Base
      OPTIONS = Base::OPTIONS.freeze

      def initialize(template, layout: :inline, **kwargs)
        super(template, layout: layout, **kwargs)
      end

      def render(object, attribute, input_id:, &block)
        @label ||= attribute.to_s.humanize
        error_override = error?(object, attribute)
        aria           = build_aria(object, attribute, input_id)
        generated_opts = build_html_options(input_id, aria)
        field_html     = @template.capture(generated_opts, @kwargs, error_override, @label, &block)
        Fields::Group.new(@template).render(layout: @layout, error: error_override) do
          @template.safe_join(
            [field_html, render_hint(input_id), render_errors(object, attribute, input_id)].compact
          )
        end
      end
    end
  end
end
