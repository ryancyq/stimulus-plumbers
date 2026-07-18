# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Checklist
      class Item
        class Slots < Plumber::Slots
          slot :title, :description
        end
      end
    end
  end
end
