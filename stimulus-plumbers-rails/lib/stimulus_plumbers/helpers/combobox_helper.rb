# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module ComboboxHelper
      def sp_combobox_date(label: nil, value: nil, **html_options)
        opts = Components::Combobox::Date.default_opts
        opts = opts.deep_merge(input:   { value: value })      if value
        opts = opts.deep_merge(trigger: { aria_label: label }) if label
        opts = opts.deep_merge(
          popover: { content: Components::Combobox::Date.new(self).render(value: value) }
        )
        Components::Combobox::Renderer.new(self).render(base_id: sp_dom_id, options: opts, **html_options)
      end

      def sp_combobox_dropdown(label: nil, options: [], value: nil, **html_options)
        opts = Components::Combobox::Dropdown.default_opts
        opts = opts.deep_merge(input:   { value: value })      if value
        opts = opts.deep_merge(trigger: { aria_label: label }) if label
        opts = opts.deep_merge(
          popover: { content: Components::Combobox::Dropdown.new(self).render(options: options, value: value) }
        )
        Components::Combobox::Renderer.new(self).render(base_id: sp_dom_id, options: opts, **html_options)
      end

      def sp_combobox_autocomplete(label: nil, options: [], value: nil, **html_options)
        opts = Components::Combobox::Autocomplete.default_opts
        opts = opts.deep_merge(input:   { value: value })      if value
        opts = opts.deep_merge(trigger: { aria_label: label }) if label
        opts = opts.deep_merge(
          popover: { content: Components::Combobox::Autocomplete.new(self).render(options: options, value: value) }
        )
        Components::Combobox::Renderer.new(self).render(base_id: sp_dom_id, options: opts, **html_options)
      end

      def sp_combobox_time(format: :h12, label: nil, step: 1, value: nil, **html_options)
        opts = Components::Combobox::Time.default_opts
        opts = opts.deep_merge(input:   { value: value })      if value
        opts = opts.deep_merge(trigger: { aria_label: label }) if label
        opts = opts.deep_merge(
          popover: { content: Components::Combobox::Time.new(self).render(format: format, step: step, value: value) }
        )
        Components::Combobox::Renderer.new(self).render(base_id: sp_dom_id, options: opts, **html_options)
      end
    end
  end
end
