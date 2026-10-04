# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Modal
      class Trigger < Plumber::Base
        STIMULUS_ACTION = "modal#open"

        def render(modal_id:, type: :default, variant: :primary, size: :md, **kwargs, &block)
          button = Components::Button.new(template)
          return render_custom(button, modal_id, type, variant, size, kwargs, &block) if block_given? && block.arity == 1

          options = merge_html_options(kwargs, command_attrs(modal_id))
          button.render(nil, type: type, variant: variant, size: size, **options, &block)
        end

        private

        def render_custom(button, modal_id, type, variant, size, kwargs, &block)
          button.build(type: type, variant: variant, size: size) do |button_attrs|
            attrs = merge_html_options(button_attrs, kwargs, { type: "button" }, command_attrs(modal_id))
            template.capture(attrs, &block)
          end
        end

        def command_attrs(modal_id)
          {
            commandfor: modal_id,
            command:    "show-modal",
            data:       { action: STIMULUS_ACTION }
          }
        end
      end
    end
  end
end
