# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Typeahead < Plumber::Base
        def self.listbox_id_for(panel_id)
          [panel_id, "listbox"].compact.join("_")
        end

        def self.variant
          Combobox.variant(:typeahead)
        end

        def self.options(**overrides)
          variant.opts(**overrides)
        end

        def render(...) = render_typeahead(...)
        def build(...) = build_typeahead(...)

        private

        def render_typeahead(panel_attrs: {}, options: [], value: nil, labelledby: nil, label: nil, url: nil)
          template.content_tag(
            :div,
            template.safe_join([render_listbox(panel_attrs[:id], options, value, labelledby, label), loading, empty]),
            **wrapper_attrs(panel_attrs: panel_attrs, url: url)
          )
        end

        def build_typeahead(panel_attrs: {}, url: nil, **_kwargs, &block)
          template.capture(wrapper_attrs(panel_attrs: panel_attrs, url: url), &block)
        end

        def wrapper_attrs(panel_attrs: {}, url: nil)
          merge_html_options(
            panel_attrs,
            {
              data: {
                controller:                  Dropdown::STIMULUS_CONTROLLER,
                action:                      Dropdown::STIMULUS_ACTION,
                combobox_dropdown_url_value: url
              }.compact
            }
          )
        end

        def render_listbox(panel_id, options, value, labelledby, label)
          template.content_tag(
            :ul,
            Options.new(template).render(options, value: value),
            **merge_html_options(
              theme.resolve(:combobox_listbox),
              {
                id:   self.class.listbox_id_for(panel_id),
                role: "listbox",
                aria: labelled_aria(label, labelledby: labelledby),
                data: { "#{Dropdown::STIMULUS_CONTROLLER}_target": "listbox" }
              }
            )
          )
        end

        def loading
          template.content_tag(
            :div,
            **merge_html_options(
              theme.resolve(:combobox_typeahead_loading),
              { hidden: "", role: "status", data: { "#{Dropdown::STIMULUS_CONTROLLER}_target": "loading" } }
            )
          ) do
            render_icon("spinner", theme: :combobox_typeahead_loading_icon)
          end
        end

        def empty
          template.content_tag(
            :div,
            **merge_html_options(
              theme.resolve(:combobox_typeahead_empty),
              { hidden: "", role: "status", data: { "#{Dropdown::STIMULUS_CONTROLLER}_target": "empty" } }
            )
          ) { I18n.t("stimulus_plumbers.combobox.typeahead.empty", default: "No results") }
        end
      end
    end
  end
end
