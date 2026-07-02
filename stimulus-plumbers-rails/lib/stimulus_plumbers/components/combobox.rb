# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox < Plumber::Base
      STIMULUS_CONTROLLER = "input-combobox"
      FORMAT_CONTROLLER   = "input-formatter"
      FORMAT_ACTION       = "input-combobox:changed->input-formatter#format"

      def render(trigger: {}, input: {}, id: nil, label: nil, close_on_select: nil, **kwargs, &block)
        trigger_opts = trigger.dup
        builder      = resolve_builder(&block)
        trigger_id   = id || trigger_opts.delete(:id) || template.sp_dom_id
        panel_id     = Popover.panel_id_for(trigger_id)

        template.content_tag(:div, **combobox_attrs(input, close_on_select, builder, panel_id, kwargs)) do
          build_popover(trigger_opts, input, builder, trigger_id, panel_id, label)
        end
      end

      private

      def resolve_builder
        builder = Combobox::Builder.new(template)
        yield builder if block_given?
        builder
      end

      def build_popover(trigger, input, builder, trigger_id, panel_id, label)
        metadata = builder.metadata

        Components::Popover.new(template).build(panel_id: panel_id) do |p|
          p.trigger(haspopup: metadata.haspopup, controls: metadata.popup_id_for(panel_id)) do |attrs|
            build_combobox_trigger(attrs, trigger, input, metadata, trigger_id, label)
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

      def build_combobox_trigger(attrs, trigger, input, metadata, trigger_id, label)
        opts = trigger_options(metadata, trigger)
        opts[:aria] = (opts[:aria] || {}).merge(label: label) if label

        template.safe_join(
          [
            Combobox::Trigger.new(template).render(
              stimulus_controller: STIMULUS_CONTROLLER,
              popover:             attrs,
              id:                  trigger_id,
              **opts
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
