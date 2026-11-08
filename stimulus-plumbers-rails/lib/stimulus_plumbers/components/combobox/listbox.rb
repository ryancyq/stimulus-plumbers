# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Listbox < Plumber::Base
        def render(...)
          render_listbox(...)
        end

        private

        def render_listbox(id:, options:, value:, aria: {})
          template.content_tag(
            :ul,
            Options.new(template).render(options, value: value, id_prefix: id),
            **merge_html_options(
              theme.resolve(:combobox_listbox),
              { id: id, role: "listbox", aria: aria, data: { "#{Combobox::STIMULUS_CONTROLLER}-target" => "listbox" } }
            )
          )
        end
      end
    end
  end
end
