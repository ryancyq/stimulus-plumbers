# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Date
        class Navigation < Plumber::Base
          def render(step:, stimulus_controller:, view: "month", date: ::Date.today, **kwargs)
            html_options = merge_html_options(
              theme.resolve(:combobox_date_navigation),
              kwargs,
              { aria: { label: t("navigation_label") } }
            )

            template.content_tag(:nav, **html_options) do
              template.safe_join(navigators(stimulus_controller, step, view, date))
            end
          end

          private

          def navigators(stimulus_controller, step, view, date)
            [
              navigator(stimulus_controller, target: "previous", icon: "arrow-left", label: prev_label(step)),
              view(stimulus_controller, view, date),
              navigator(stimulus_controller, target: "next", icon: "arrow-right", label: next_label(step))
            ]
          end

          def navigator(stimulus_controller, target:, label:, icon: nil)
            opts = {
              aria: { label: label },
              data: { "#{stimulus_controller}-target" => target }
            }
            opts[:icon] = icon if icon
            Navigator.new(template).render(**opts)
          end

          def view(stimulus_controller, view, date)
            html_options = merge_html_options(
              theme.resolve(:combobox_date_navigation_title),
              data: {
                "#{stimulus_controller}-target" => "viewTitle",
                action:                           "click->#{stimulus_controller}#zoomOut"
              }
            )
            Components::Button.new(template).render(
              type: :ghost, variant: :tertiary, size: nil, **html_options
            ) { view_label(view, date) }
          end

          def view_label(view, date)
            case view
            when "year"   then date.year.to_s
            when "decade" then decade_label(date)
            else               I18n.l(date, format: "%B %Y")
            end
          end

          def decade_label(date)
            start = (date.year / 10) * 10
            "#{start}–#{start + 9}"
          end

          def prev_label(step)
            t("previous_#{step}")
          end

          def next_label(step)
            t("next_#{step}")
          end

          def t(key)
            I18n.t("stimulus_plumbers.combobox.date.#{key}")
          end
        end
      end
    end
  end
end
