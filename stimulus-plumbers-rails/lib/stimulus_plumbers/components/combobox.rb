# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox < Plumber::Base
      STIMULUS_CONTROLLER = "input-combobox"
      FORMAT_CONTROLLER   = "input-formatter"
      FORMAT_ACTION       = "input-combobox:changed->input-formatter#format"

      def self.popover_id_for(trigger_id)
        [trigger_id, "popover"].compact.join("_")
      end

      def render(...)
        render_combobox(...)
      end

      private

      def render_combobox(trigger: {}, input: {}, popover: {}, **kwargs, &block)
        html_options = merge_html_options(
          { classes: theme.resolve(:combobox).fetch(:classes, ""), data: build_stimulus_data(input[:value]) },
          kwargs
        )

        template.content_tag(:div, **html_options) do
          template.safe_join(
            [
              combobox_trigger(trigger, popover),
              hidden_input(input),
              combobox_popover(trigger, popover, &block)
            ]
          )
        end
      end

      def build_stimulus_data(initial_value)
        {
          controller: "#{STIMULUS_CONTROLLER} #{FORMAT_CONTROLLER}",
          action:     FORMAT_ACTION
        }.tap do |data|
          data[:input_combobox_value_value] = initial_value if initial_value.present?
        end
      end

      def combobox_trigger(trigger, popover)
        Combobox::Trigger.new(template).render(
          stimulus_controller: STIMULUS_CONTROLLER,
          popover_id:          self.class.popover_id_for(trigger[:id]),
          haspopup:            popover.delete(:haspopup) { popover[:role] || "dialog" },
          **trigger
        )
      end

      def combobox_popover(trigger, popover, &block)
        Combobox::Popover.new(template).render(
          stimulus_controller: STIMULUS_CONTROLLER,
          id:                  self.class.popover_id_for(trigger[:id]),
          **popover,
          &block
        )
      end

      def hidden_input(input)
        stimulus_data = merge_html_options(
          { "#{STIMULUS_CONTROLLER}_target": "input" },
          input.fetch(:data, {})
        )
        template.tag.input(type: "hidden", name: input[:name], value: input[:value], data: stimulus_data)
      end
    end
  end
end
