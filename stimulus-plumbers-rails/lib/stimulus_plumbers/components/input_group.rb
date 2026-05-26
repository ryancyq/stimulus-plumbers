# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class InputGroup < Plumber::Base
      def render(leading: nil, trailing: nil, error: false, **kwargs, &block)
        html_options = merge_html_options(
          theme.resolve(:input_group, error: error),
          kwargs
        )
        template.content_tag(:div, **html_options) do
          build_input_group(leading, trailing, &block)
        end
      end

      private

      def build_input_group(leading, trailing, &block)
        template.safe_join(
          [
            leading.respond_to?(:call) ? leading.call : leading,
            template.capture(&block),
            trailing.respond_to?(:call) ? trailing.call : trailing
          ]
        )
      end
    end
  end
end
