# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox < Plumber::Base
      STIMULUS_CONTROLLER = "input-combobox"
      FORMAT_CONTROLLER   = "input-format"
      FORMAT_ACTION       = "input-combobox:changed->input-format#format"

      def render(base_id:, options: {}, **kwargs, &block)
        popover_id    = "#{base_id}_popover"
        initial_value = options.dig(:input, :value)

        base_data = {
          controller: "#{STIMULUS_CONTROLLER} #{FORMAT_CONTROLLER}",
          action:     FORMAT_ACTION
        }
        base_data[:input_combobox_value_value] = initial_value if initial_value.present?

        html_options = merge_html_options({ data: base_data }, kwargs)

        template.content_tag(:div, **html_options) do
          template.safe_join(
            [
              trigger(popover_id, options),
              hidden_input(options.fetch(:input, {})),
              popover(popover_id, options, &block)
            ]
          )
        end
      end

      def trigger(popover_id, options)
        haspopup = options.dig(:popover, :haspopup) || options.dig(:popover, :role) || "dialog"
        Combobox::Trigger.new(template).render(
          stimulus_controller: STIMULUS_CONTROLLER,
          popover_id:          popover_id,
          haspopup:            haspopup,
          **options.fetch(:trigger, {})
        )
      end

      def popover(popover_id, options, &block)
        Combobox::Popover.new(template).render(
          stimulus_controller: STIMULUS_CONTROLLER,
          id:                  popover_id,
          **options.fetch(:popover, {}),
          &block
        )
      end

      private

      def hidden_input(opts)
        data = { "#{STIMULUS_CONTROLLER}_target": "value" }.merge(opts.fetch(:data, {}))
        template.tag.input(type: "hidden", name: opts[:name], value: opts[:value], data: data)
      end
    end
  end
end
