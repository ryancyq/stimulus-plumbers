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

      def render(trigger: {}, input: {}, close_on_select: nil, **kwargs, &block)
        builder  = resolve_builder(&block)
        panel_id = self.class.panel_id_for(trigger[:id])

        template.content_tag(:div, **combobox_attrs(input, close_on_select, builder, panel_id, kwargs)) do
          build_popover(trigger, input, builder, panel_id)
        end
      end

      private

      def resolve_builder
        builder = Combobox::Builder.new
        yield builder if block_given?
        builder
      end

      def build_popover(trigger, input, builder, panel_id)
        metadata = builder.metadata

        Components::Popover.new(template).build(panel_id: panel_id) do |p|
          p.trigger(haspopup: metadata.haspopup, controls: metadata.popup_id_for(panel_id)) do |attrs|
            build_combobox_trigger(attrs, trigger, input, metadata)
          end
          p.build_panel(classes: theme.resolve(:combobox_popover).fetch(:classes, "")) do |panel_attrs|
            builder.render_panel(template, panel_attrs: panel_attrs)
          end
        end
      end

      def combobox_attrs(input, close_on_select, builder, panel_id, kwargs)
        merge_html_options(
          theme.resolve(:combobox),
          kwargs,
          { data: stimulus_data(input[:value], close_on_select) },
          { data: builder.metadata.stimulus_data(panel_id, builder.options) }
        )
      end

      def build_combobox_trigger(attrs, trigger, input, metadata)
        template.safe_join(
          [
            Combobox::Trigger.new(template).render(
              stimulus_controller: STIMULUS_CONTROLLER,
              popover:             attrs,
              **trigger_options(metadata, trigger)
            ),
            hidden_input(input)
          ]
        )
      end

      def trigger_options(metadata, trigger)
        defaults = metadata.trigger_options.dup
        defaults[:icon_trailing] = metadata.trigger_icon if metadata.trigger_icon
        defaults.deep_merge(trigger)
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
