# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox < Plumber::Base
      STIMULUS_CONTROLLER = "input-combobox"
      FORMAT_CONTROLLER   = "input-formatter"
      FORMAT_ACTION       = "input-combobox:changed->input-formatter#format"

      def self.panel_id_for(trigger_id)
        [trigger_id, "popover"].compact.join("_")
      end

      def self.variants
        @variants ||= {
          dropdown:  Variant.new(haspopup: "listbox", panel_class: Dropdown),
          typeahead: Variant.new(
            haspopup:        "listbox",
            panel_class:     Typeahead,
            popup_id_suffix: "listbox",
            default_opts:    { trigger: { aria: { autocomplete: "list" }, readonly: false } }
          ),
          date:      Variant.new(
            haspopup:     "dialog",
            panel_class:  Date,
            default_opts: { input: { data: { combobox_date_date_value: nil } } }
          ),
          time:      Variant.new(haspopup: "dialog", panel_class: Time)
        }.freeze
      end

      def self.variant(name)
        variants.fetch(name)
      end

      def render(...) = render_combobox(...)
      def build(...) = build_combobox(...)

      private

      def render_combobox(trigger: {}, input: {}, haspopup: "dialog", popup_id: nil, close_on_select: nil, **kwargs, &block)
        template.content_tag(:div, **combobox_attrs(input, close_on_select, kwargs)) do
          build_combobox(trigger: trigger, input: input, haspopup: haspopup, popup_id: popup_id, &block)
        end
      end

      def build_combobox(trigger: {}, input: {}, haspopup: "dialog", popup_id: nil, **_kwargs, &block)
        panel_id = self.class.panel_id_for(trigger[:id])

        Components::Popover.new(template).build(panel_id: panel_id) do |p|
          p.trigger(haspopup: haspopup, controls: popup_id || panel_id) do |attrs|
            build_combobox_trigger(attrs, trigger, input)
          end
          p.build_panel(classes: theme.resolve(:combobox_popover).fetch(:classes, ""), &block)
        end
      end

      def combobox_attrs(input, close_on_select, kwargs)
        merge_html_options(
          theme.resolve(:combobox),
          kwargs,
          { data: stimulus_data(input[:value], close_on_select) }
        )
      end

      def build_combobox_trigger(attrs, trigger, input)
        template.safe_join(
          [
            Combobox::Trigger.new(template).render(
              stimulus_controller: STIMULUS_CONTROLLER,
              popover:             attrs,
              **trigger
            ),
            hidden_input(input)
          ]
        )
      end

      def stimulus_data(initial_value, close_on_select)
        data = {
          controller: "#{Popover::STIMULUS_CONTROLLER} #{STIMULUS_CONTROLLER} #{FORMAT_CONTROLLER}",
          action:     FORMAT_ACTION
        }
        data[:input_combobox_value_value]    = initial_value if initial_value.present?
        data[:popover_close_on_select_value] = close_on_select unless close_on_select.nil?
        data
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
