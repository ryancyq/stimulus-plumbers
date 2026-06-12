# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Typeahead < Plumber::Base
        def self.listbox_id_for(panel_id)
          [panel_id, "listbox"].compact.join("_")
        end

        module Metadata
          module_function

          def haspopup = "listbox"
          def popup_id_for(panel_id) = Typeahead.listbox_id_for(panel_id)
          def trigger_icon = nil
          def trigger_options = { readonly: false, aria: { autocomplete: "list" } }

          def stimulus_data(panel_id, _options)
            {
              input_combobox_combobox_dropdown_outlet: "##{panel_id}",
              action:                                  "input->#{Combobox::STIMULUS_CONTROLLER}#onInput"
            }
          end
        end

        def render(...) = render_typeahead(...)

        private

        def render_typeahead(panel_attrs: {}, options: [], value: nil, labelledby: nil, label: nil, url: nil)
          template.content_tag(
            :div,
            template.safe_join([render_listbox(panel_attrs[:id], options, value, labelledby, label), loading, empty]),
            **wrapper_attrs(panel_attrs: panel_attrs, url: url)
          )
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
            Components::Icon.new(template).render(
              name:    "spinner",
              classes: theme.resolve(:combobox_typeahead_loading_icon).fetch(:classes, ""),
              aria:    { hidden: "true" }
            )
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
