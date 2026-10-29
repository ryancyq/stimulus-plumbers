# frozen_string_literal: true

module StimulusPlumbers
  module Components
    # The `combobox` controller markup: root, Trigger, hidden input, and Panel. Dropdown and Typeahead define MODE
    # and the trigger element.
    class Combobox < Plumber::Base
      include Plumber::Options::Choice

      STIMULUS_CONTROLLER = "combobox"

      class << self
        def listbox_id_for(panel_id)
          [panel_id, "listbox"].compact.join("_")
        end
      end

      def render(
        name: nil,
        options: [],
        value: nil,
        label: nil,
        labelledby: nil,
        id: nil,
        close_on_commit: nil,
        trigger: {},
        **kwargs
      )
        @ids     = ids_for(id || template.sp_dom_id)
        @options = options
        @value   = value&.to_s
        group    = kwargs.extract!(:icon_leading, :icon_trailing, :trailing)

        template.content_tag(:div, **root_attrs(close_on_commit, kwargs)) do
          template.safe_join(
            [
              render_trigger(label, labelledby, group.merge(trigger)),
              hidden_input(name),
              render_panel(labelled_aria(label, labelledby: labelledby))
            ]
          )
        end
      end

      private

      def ids_for(trigger_id)
        panel_id = Popover.panel_id_for(trigger_id)
        { trigger: trigger_id, panel: panel_id, listbox: self.class.listbox_id_for(panel_id) }
      end

      def render_trigger(label, labelledby, trigger)
        Trigger.new(template).render(
          id:         @ids[:trigger],
          listbox_id: @ids[:listbox],
          actions:    trigger_actions,
          **trigger_options(trigger),
          aria:       trigger_aria.merge(labelled_aria(label, labelledby: labelledby)).merge(trigger.fetch(:aria, {}))
        ) { |attrs| render_host(attrs) }
      end

      # Trigger options; Dropdown adds its default icon.
      def trigger_options(trigger)
        trigger
      end

      # Actions before the shared keydown; Typeahead adds input.
      def trigger_actions
        []
      end

      def trigger_aria
        {}
      end

      def display_label
        Options.new(template).label_for(@options, @value).to_s
      end

      def root_attrs(close_on_commit, kwargs)
        data = {
          controller:             STIMULUS_CONTROLLER,
          action:                 "mousedown->#{STIMULUS_CONTROLLER}#onMousedown click->#{STIMULUS_CONTROLLER}#onClick",
          "combobox-mode-value" => self.class::MODE
        }
        data["combobox-close-on-commit-value"] = close_on_commit.to_s unless close_on_commit.nil?

        merge_html_options(theme.resolve(:combobox), kwargs, { data: data }, *root_options)
      end

      # Root options merged after the combobox's own.
      def root_options
        []
      end

      def render_panel(aria)
        Panel.new(template).render(id: @ids[:panel]) do
          panel_content(Listbox.new(template).render(id: @ids[:listbox], options: @options, value: @value, aria: aria))
        end
      end

      def panel_content(listbox)
        listbox
      end

      def hidden_input(name)
        template.tag.input(type: "hidden", name: name, value: @value, data: { "#{STIMULUS_CONTROLLER}-target" => "input" })
      end
    end
  end
end
