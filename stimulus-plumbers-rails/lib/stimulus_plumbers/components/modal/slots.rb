# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Modal
      class Slots < Plumber::Slots
        include Plumber::Options::Html

        def initialize(template, modal_id:)
          super(template)
          @modal_id = modal_id
        end

        def trigger(type: :default, variant: :primary, size: :md, **kwargs, &block)
          html = Modal::Trigger.new(@template).render(
            modal_id: @modal_id, type: type, variant: variant, size: size, **kwargs, &block
          )
          set_slot(:trigger, html)
        end

        def header(&block)
          set_required_block(:header, block)
        end

        def body(&block)
          set_required_block(:body, block)
        end

        def footer(&block)
          set_required_block(:footer, block)
        end

        def dismiss_button(content = nil, result: nil, **kwargs, &block)
          render_button(content, action: "dismiss", result: result, **kwargs, &block)
        end

        def close_button(content = nil, result: nil, **kwargs, &block)
          render_button(content, action: "close", result: result, **kwargs, &block)
        end

        private

        def set_required_block(name, block)
          raise ArgumentError, "modal.#{name} requires a block" unless block

          set_slot(name, block)
        end

        def render_button(content, action:, result:, **kwargs, &block)
          data = { action: "modal##{action}" }
          data[:modal_result_param] = result unless result.nil?
          native = {
            commandfor: @modal_id,
            command:    action == "dismiss" ? "request-close" : "close",
            data:       data
          }
          native[:value] = result unless result.nil?
          button_options = merge_html_options(kwargs, native)

          Components::Button.new(@template).render(content, **button_options, &block)
        end
      end
    end
  end
end
