# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module ComboboxHelper
      def sp_combobox_date(**kwargs)
        label = kwargs.delete(:label)
        value = kwargs.delete(:value)
        id    = sp_dom_id
        opts  = Components::Combobox::Date.options(
          input:   { value: value },
          trigger: { id: id, aria: ({ label: label } if label), icon_trailing: "calendar" }.compact
        )
        extra = { data: { input_formatter_format_value: "date" }, **kwargs }
        sp_render_combobox(Components::Combobox::Date, id, opts, **extra) do |panel_attrs|
          Components::Combobox::Date.new(self).render(panel_attrs: panel_attrs, value: value)
        end
      end

      def sp_combobox_dropdown(**kwargs)
        label   = kwargs.delete(:label)
        value   = kwargs.delete(:value)
        options = kwargs.delete(:options) { [] }
        id      = sp_dom_id
        opts    = Components::Combobox::Dropdown.options(
          input:   { value: value },
          trigger: { id: id, aria: ({ label: label } if label), icon_trailing: "chevron-down" }.compact
        )
        sp_render_combobox(Components::Combobox::Dropdown, id, opts, **kwargs) do |panel_attrs|
          Components::Combobox::Dropdown.new(self).render(
            panel_attrs: panel_attrs, options: options, value: value, label: label
          )
        end
      end

      def sp_combobox_typeahead(**kwargs)
        label   = kwargs.delete(:label)
        value   = kwargs.delete(:value)
        options = kwargs.delete(:options) { [] }
        url     = kwargs.delete(:url)
        id      = sp_dom_id
        opts    = Components::Combobox::Typeahead.options(
          input:   { value: value },
          trigger: { id: id, aria: ({ label: label } if label) }.compact
        )
        sp_render_combobox(Components::Combobox::Typeahead, id, opts, data: typeahead_data(id), **kwargs) do |panel_attrs|
          Components::Combobox::Typeahead.new(self).render(
            panel_attrs: panel_attrs, options: options, value: value, label: label, url: url
          )
        end
      end

      def sp_combobox_time(**kwargs)
        format = kwargs.delete(:format) { :h12 }
        label  = kwargs.delete(:label)
        step   = kwargs.delete(:step) { 1 }
        value  = kwargs.delete(:value)
        id     = sp_dom_id
        opts   = Components::Combobox::Time.options(
          input:   { value: value },
          trigger: { id: id, aria: ({ label: label } if label), icon_trailing: "clock" }.compact
        )
        data = { input_formatter_format_value: "time", input_formatter_options_value: { format: format }.to_json }
        sp_render_combobox(Components::Combobox::Time, id, opts, data: data, **kwargs) do |panel_attrs|
          Components::Combobox::Time.new(self).render(panel_attrs: panel_attrs, format: format, step: step, value: value)
        end
      end

      private

      def sp_render_combobox(variant_class, id, opts, **kwargs, &block)
        variant  = variant_class.variant
        panel_id = Components::Combobox.panel_id_for(id)
        Components::Combobox.new(self).render(
          **opts,
          haspopup: variant.haspopup,
          popup_id: variant.popup_id_for(panel_id),
          **kwargs,
          &block
        )
      end

      def typeahead_data(id)
        {
          input_combobox_combobox_dropdown_outlet: "##{Components::Combobox.panel_id_for(id)}",
          action:                                  "input->input-combobox#onInput"
        }
      end
    end
  end
end
