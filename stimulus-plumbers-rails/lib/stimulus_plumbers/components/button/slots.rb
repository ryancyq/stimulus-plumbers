# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Button
      class Slots < Plumber::Slots
        slot :icon_leading, :icon_trailing
      end
    end
  end
end
