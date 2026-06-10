# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Card
      class Slots < Plumber::Slots
        slot :icon, :title

        def with_body(&block)
          raise ArgumentError, "card.body requires a block" unless block

          set_slot(:body, block)
          nil
        end

        # Defined manually (not via `slot` DSL) because it requires a named `url:` keyword with validation.
        def with_action(value = nil, url: nil, &block)
          raise ArgumentError, "card.action requires content (string or block) when url: is given" if url && value.nil? && !block

          set_slot(:action, block || value, url ? { url: url } : {})
          nil
        end
      end
    end
  end
end
