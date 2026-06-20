# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Timeline
      class Event
        class Slots < Plumber::Slots
          # Define slots using short names (without with_ prefix) for the Timeline event DSL.
          # Standard slot DSL is not used here because the timeline API uses e.time { } not e.with_time { }.

          def indicator(icon: nil)
            set_slot(:indicator, icon, { type: icon ? :icon : :dot, icon: icon })
            nil
          end

          def indicator?
            @slots.key?(:indicator)
          end

          def time(&block)
            raise ArgumentError, "timeline event time requires a block" unless block

            set_slot(:time, block)
            nil
          end

          def time?
            @slots.key?(:time)
          end

          def title(&block)
            raise ArgumentError, "timeline event title requires a block" unless block

            set_slot(:title, block)
            nil
          end

          def title?
            @slots.key?(:title)
          end

          def trigger(&block)
            raise ArgumentError, "timeline event trigger requires a block" unless block

            set_slot(:trigger, block)
            nil
          end

          def trigger?
            @slots.key?(:trigger)
          end

          def description(&block)
            raise ArgumentError, "timeline event description requires a block" unless block

            set_slot(:description, block)
            nil
          end

          def description?
            @slots.key?(:description)
          end

          def detail(&block)
            raise ArgumentError, "timeline event detail requires a block" unless block

            set_slot(:detail, block)
            nil
          end

          def detail?
            @slots.key?(:detail)
          end

          def actions(&block)
            raise ArgumentError, "timeline event actions requires a block" unless block

            set_slot(:actions, block)
            nil
          end

          def actions?
            @slots.key?(:actions)
          end
        end
      end
    end
  end
end
