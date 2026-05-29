# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module ComboboxHelper
      def sp_combobox_date(**kwargs)
        label    = kwargs.delete(:label)
        value    = kwargs.delete(:value)
        id       = sp_dom_id
        panel_id = Components::Combobox.panel_id_for(id)
        opts     = Components::Combobox::Date.default_opts.deep_merge(
          input:   { value: value },
          trigger: { id: id, aria: ({ label: label } if label), icon_trailing: "calendar" }.compact
        )
        Components::Combobox.new(self).render(
          **opts,
          haspopup: Components::Combobox::Date.haspopup,
          popup_id: Components::Combobox::Date.popup_id(panel_id),
          data:     { input_formatter_format_value: "date" },
          **kwargs
        ) do |pid, panel_attrs|
          Components::Combobox::Date.new(self).render(panel_id: pid, panel_attrs: panel_attrs, value: value)
        end
      end

      def sp_combobox_dropdown(**kwargs)
        label    = kwargs.delete(:label)
        value    = kwargs.delete(:value)
        options  = kwargs.delete(:options) { [] }
        id       = sp_dom_id
        panel_id = Components::Combobox.panel_id_for(id)
        opts     = {
          input:   { value: value },
          trigger: { id: id, aria: ({ label: label } if label), icon_trailing: "chevron-down" }.compact
        }
        Components::Combobox.new(self).render(
          **opts,
          haspopup: Components::Combobox::Dropdown.haspopup,
          popup_id: Components::Combobox::Dropdown.popup_id(panel_id),
          **kwargs
        ) do |_pid, panel_attrs|
          Components::Combobox::Dropdown.new(self).render(
            panel_attrs: panel_attrs, options: options, value: value, label: label
          )
        end
      end

      # rubocop:disable Metrics/AbcSize
      def sp_combobox_typeahead(**kwargs)
        label    = kwargs.delete(:label)
        value    = kwargs.delete(:value)
        options  = kwargs.delete(:options) { [] }
        url      = kwargs.delete(:url)
        id       = sp_dom_id
        panel_id = Components::Combobox.panel_id_for(id)
        opts     = Components::Combobox::Typeahead.default_opts.deep_merge(
          input:   { value: value },
          trigger: { id: id, aria: ({ label: label } if label) }.compact
        )
        Components::Combobox.new(self).render(
          **opts,
          haspopup: Components::Combobox::Typeahead.haspopup,
          popup_id: Components::Combobox::Typeahead.popup_id(panel_id),
          data:     {
            input_combobox_combobox_dropdown_outlet: "##{panel_id}",
            action:                                  "input->input-combobox#onInput"
          },
          **kwargs
        ) do |pid, panel_attrs|
          Components::Combobox::Typeahead.new(self).render(
            panel_id: pid, panel_attrs: panel_attrs, options: options, value: value, label: label, url: url
          )
        end
      end
      # rubocop:enable Metrics/AbcSize

      def sp_combobox_time(**kwargs)
        format   = kwargs.delete(:format) { :h12 }
        label    = kwargs.delete(:label)
        step     = kwargs.delete(:step) { 1 }
        value    = kwargs.delete(:value)
        id       = sp_dom_id
        panel_id = Components::Combobox.panel_id_for(id)
        opts     = {
          input:   { value: value },
          trigger: { id: id, aria: ({ label: label } if label), icon_trailing: "clock" }.compact
        }
        Components::Combobox.new(self).render(
          **opts,
          haspopup: Components::Combobox::Time.haspopup,
          popup_id: Components::Combobox::Time.popup_id(panel_id),
          data:     { input_formatter_format_value: "time", input_formatter_options_value: { format: format }.to_json },
          **kwargs
        ) do |_pid, panel_attrs|
          Components::Combobox::Time.new(self).render(
            panel_attrs: panel_attrs, format: format, step: step, value: value
          )
        end
      end
    end
  end
end
