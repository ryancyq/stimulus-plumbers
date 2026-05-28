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

      # rubocop:disable Metrics/AbcSize
      def render_combobox(trigger: {}, input: {}, popover: {}, **kwargs, &block)
        panel_id     = self.class.popover_id_for(trigger[:id])
        html_options = merge_html_options(
          { classes: theme.resolve(:combobox).fetch(:classes, ""),
            data:    build_stimulus_data(input[:value])
},
          kwargs
        )
        haspopup = popover.delete(:haspopup) { popover[:role] || "dialog" }

        template.content_tag(:div, **html_options) do
          Components::Popover.new(template).build(panel_id: panel_id) do |p|
            p.trigger(haspopup: haspopup) { |attrs| build_combobox_trigger(attrs, trigger, input) }
            p.panel(**build_panel_options(popover), &block)
          end
        end
      end
      # rubocop:enable Metrics/AbcSize

      def build_combobox_trigger(attrs, trigger, input)
        template.safe_join(
          [
            Combobox::Trigger.new(template).render(
              stimulus_controller: STIMULUS_CONTROLLER,
              popover_id:          attrs[:panel_id],
              haspopup:            attrs[:aria][:haspopup],
              **trigger
            ),
            hidden_input(input)
          ]
        )
      end

      def build_panel_options(popover)
        merge_html_options(
          { classes: theme.resolve(:combobox_popover).fetch(:classes, "") },
          { data:    { "#{STIMULUS_CONTROLLER}_target": "popover" } },
          popover
        )
      end

      def build_stimulus_data(initial_value)
        {
          controller: "#{STIMULUS_CONTROLLER} #{FORMAT_CONTROLLER}",
          action:     FORMAT_ACTION
        }.tap do |data|
          data[:input_combobox_value_value] = initial_value if initial_value.present?
        end
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
