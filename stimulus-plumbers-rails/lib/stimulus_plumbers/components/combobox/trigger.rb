# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      # The role=combobox element inside its TriggerGroup; the block renders the element from its attributes.
      class Trigger < Plumber::Base
        def render(...)
          render_trigger(...)
        end

        private

        def render_trigger(icon_leading: nil, icon_trailing: nil, trailing: nil, **kwargs, &host)
          TriggerGroup.new(template).render(icon_leading: icon_leading, icon_trailing: icon_trailing, trailing: trailing) do
            host.call(host_attrs(**kwargs))
          end
        end

        def host_attrs(id:, listbox_id:, actions: [], aria: {}, data: {}, **kwargs)
          merge_html_options(
            theme.resolve(:combobox_trigger),
            {
              id:   id,
              role: "combobox",
              aria: { expanded: "false", controls: listbox_id }.merge(aria),
              data: { "#{Combobox::STIMULUS_CONTROLLER}-target" => "trigger" }
            },
            { data: { action: [*actions, "keydown->#{Combobox::STIMULUS_CONTROLLER}#onKeydown"].join(" ") } },
            { data: data },
            kwargs
          )
        end
      end
    end
  end
end
