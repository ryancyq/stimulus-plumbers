# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Timeline
      class Event
        class Slots < Plumber::Slots
          slot :indicator, :time, :title, :trigger, :description, :detail, :actions

          def with_indicator(icon: nil)
            set_slot(:indicator, icon, { type: icon ? :icon : :dot, icon: icon })
          end
        end
      end
    end
  end
end
