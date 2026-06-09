# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class List
      class Item
        class Slots < Plumber::Slots
          slot :icon_leading, :title, :description, :icon_trailing
        end
      end
    end
  end
end
