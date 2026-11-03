# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      # A read-only input formatted by input-formatter, with a hidden input and a popover panel.
      # Subclasses define STIMULUS_CONTROLLER, FORMAT, ICON, POPOVER_KEY, AVAILABILITY, ACTIONS, `parse`, `canonical`, and
      # `render_panel`.
      class Temporal < Plumber::Base
        FORMAT_CONTROLLER = "input-formatter"
        TRIGGER_OPTIONS   = %i[open_on_focus icon_leading icon_trailing trigger].freeze

        # `format:` is the input-formatter options, with `locale` defaulting to the I18n locale.
        # Trigger options: `open_on_focus:`, `icon_leading:`, `icon_trailing:`, `trigger:`.
        def render(name: nil, value: nil, label: nil, labelledby: nil, id: nil, format: {}, **kwargs)
          @id     = (id || template.sp_dom_id).to_s
          @value  = parse(value) unless value.blank?
          @text   = @value ? canonical(@value) : value.to_s
          @format = format_options(format)
          trigger = trigger_options(kwargs)

          template.content_tag(:div, **root_attrs(kwargs)) do
            render_popover(labelled_aria(label, labelledby: labelledby), name, trigger)
          end
        end

        private

        def render_popover(name_aria, name, trigger)
          Popover.new(template).build(panel_id: Popover.panel_id_for(@id)) do |popover|
            popover.trigger(haspopup: "dialog") { |attrs| render_trigger(attrs[:aria].merge(name_aria), name, trigger) }
            popover.build_panel(**panel_attrs(name_aria)) { |panel_attrs| render_panel(panel_attrs) }
          end
        end

        def trigger_options(kwargs)
          { icon_trailing: self.class::ICON }.merge(kwargs.extract!(*TRIGGER_OPTIONS))
        end

        def root_attrs(kwargs)
          controller = self.class::STIMULUS_CONTROLLER
          merge_html_options(
            theme.resolve(:combobox),
            kwargs,
            {
              data: {
                controller:                          [Popover::STIMULUS_CONTROLLER, controller, FORMAT_CONTROLLER].join(" "),
                action:                              [
                  *self.class::ACTIONS,
                  "focusout->#{controller}#onFocusout",
                  "mousedown->#{controller}#onMousedown",
                  "click->#{controller}#onClick",
                  "#{controller}:changed->#{FORMAT_CONTROLLER}#onChange"
                ].join(" "),
                "#{FORMAT_CONTROLLER}-format-value"  => self.class::FORMAT,
                "#{FORMAT_CONTROLLER}-options-value" => @format.to_json
              }
            }
          )
        end

        # Intl takes BCP 47 tags, so `pt_BR` becomes `pt-BR`; a value without `to_h` passes as is.
        def format_options(format)
          return format unless format.respond_to?(:to_h)

          { locale: I18n.locale.to_s.tr("_", "-") }.merge(format.to_h.transform_keys(&:to_sym))
        end

        def render_trigger(aria, name, trigger)
          controller = self.class::STIMULUS_CONTROLLER
          template.safe_join(
            [
              Trigger.new(template).render(controller: controller, id: @id, value: @text, aria: aria, **trigger),
              template.tag.input(type: "hidden", name: name, value: @text, data: { "#{controller}-target" => "input" })
            ]
          )
        end

        # An external label names the panel; otherwise "Choose <label>".
        def panel_attrs(name_aria)
          labelledby = name_aria[:labelledby]
          {
            role:    "dialog",
            classes: theme.resolve(self.class::POPOVER_KEY).fetch(:classes, ""),
            data:    { "#{self.class::STIMULUS_CONTROLLER}-target" => "panel" },
            **(labelledby ? { aria_labelledby: labelledby } : { aria_label: panel_label(name_aria[:label]) })
          }
        end

        def panel_label(label)
          scope = "stimulus_plumbers.combobox.#{self.class::FORMAT}"
          I18n.t("#{scope}.dialog", label: label || I18n.t("#{scope}.label"))
        end
      end
    end
  end
end
