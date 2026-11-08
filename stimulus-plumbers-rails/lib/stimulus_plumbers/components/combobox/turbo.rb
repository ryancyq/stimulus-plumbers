# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      # Turbo loading: `combobox-turbo` loads `source` results into a Turbo Frame around the listbox.
      class Turbo < Plumber::Base
        TURBO_CONTROLLER = "combobox-turbo"
        ACTIONS          = [
          "#{STIMULUS_CONTROLLER}:query->#{TURBO_CONTROLLER}#onQuery",
          "#{STIMULUS_CONTROLLER}:closed->#{TURBO_CONTROLLER}#onClosed"
        ].join(" ").freeze
        FRAME_ACTIONS = [
          "turbo:before-fetch-response->#{TURBO_CONTROLLER}#onResponse",
          "turbo:frame-missing->#{TURBO_CONTROLLER}#onError",
          "turbo:fetch-request-error->#{TURBO_CONTROLLER}#onError"
        ].join(" ").freeze

        def initialize(template, source, param)
          super(template)
          @source = source
          @param  = param
        end

        def stimulus_data
          {
            controller:                          TURBO_CONTROLLER,
            action:                              ACTIONS,
            "combobox-turbo-src-value"          => @source.to_s,
            "combobox-turbo-param-value"        => @param&.to_s,
            "combobox-turbo-loading-text-value" => I18n.t("stimulus_plumbers.combobox.typeahead.loading"),
            "combobox-turbo-error-text-value"   => I18n.t("stimulus_plumbers.combobox.typeahead.error")
          }.compact
        end

        # The listbox in `turbo-frame#<panel id>_results`, the frame the source response must hold.
        def render(panel_id, listbox)
          template.content_tag(
            :"turbo-frame",
            listbox,
            id:   "#{panel_id}_results",
            data: { "#{TURBO_CONTROLLER}-target" => "frame", action: FRAME_ACTIONS }
          )
        end

        def status_data
          { "#{TURBO_CONTROLLER}-target" => "status" }
        end
      end
    end
  end
end
