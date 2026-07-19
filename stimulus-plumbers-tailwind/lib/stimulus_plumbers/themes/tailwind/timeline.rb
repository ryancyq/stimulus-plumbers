# frozen_string_literal: true

require_relative "timeline/group"

module StimulusPlumbers
  module Themes
    module Tailwind
      module Timeline
        TRACK_VERTICAL   = %w[flex flex-col gap-y-10].freeze
        TRACK_HORIZONTAL = %w[flex].freeze

        TRACK_LINE_VERTICAL = %w[absolute inset-y-0 start-3 w-px bg-(--sp-color-border)].freeze

        ITEM_VERTICAL    = %w[flex gap-x-4 items-start].freeze
        ITEM_HORIZONTAL  = %w[relative flex-1].freeze

        ITEM_INDICATOR_DOT = %w[
          mt-1 flex shrink-0 size-6 items-center justify-center rounded-full z-10
          bg-(--sp-color-bg) ring-4 ring-(--sp-color-bg)
        ].freeze

        ITEM_INDICATOR_ICON = %w[
          mt-1 flex shrink-0 size-6 items-center justify-center rounded-full z-10
          bg-(--sp-color-primary) text-(--sp-color-primary-fg)
          ring-4 ring-(--sp-color-bg)
        ].freeze

        ITEM_INDICATOR_ICON_SLOT = %w[stroke-current].freeze

        ITEM_INDICATOR_DOT_HORIZONTAL = %w[
          z-10 flex shrink-0 size-6 items-center justify-center rounded-full
          bg-(--sp-color-bg) ring-4 ring-(--sp-color-bg)
        ].freeze

        ITEM_INDICATOR_ICON_HORIZONTAL = %w[
          z-10 flex shrink-0 size-6 items-center justify-center rounded-full
          bg-(--sp-color-primary) text-(--sp-color-primary-fg)
          ring-4 ring-(--sp-color-bg)
        ].freeze

        ITEM_CONNECTOR_HORIZONTAL = %w[w-full h-px bg-(--sp-color-border) last:hidden].freeze
        ITEM_CONTENT_HORIZONTAL   = %w[mt-3 pe-2].freeze

        ITEM_TIME        = %w[mb-1 block text-sm leading-none text-(--sp-color-muted-fg)].freeze
        ITEM_TIME_BADGE  = %w[
          mb-1 inline-block
          bg-(--sp-color-bg-muted) border border-(--sp-color-border)
          text-(--sp-color-fg) text-xs font-medium px-1.5 py-0.5 rounded
        ].freeze
        ITEM_TITLE       = %w[mb-1 text-base font-semibold text-(--sp-color-fg)].freeze
        ITEM_HEADING     = %w[mb-1].freeze
        ITEM_TRIGGER     = [
          *Control::BASE,
          "w-full text-left text-base font-semibold",
          "text-(--sp-color-fg)",
          "hover:text-(--sp-color-primary)",
          "focus-visible:ring-(--sp-color-primary-ring) focus-visible:rounded-sm"
        ].freeze
        ITEM_DESCRIPTION = %w[text-sm text-(--sp-color-muted-fg)].freeze
        ITEM_DETAIL      = %w[mt-2 text-sm text-(--sp-color-muted-fg)].freeze
        ITEM_ACTIONS     = %w[mt-3 flex flex-wrap items-center gap-2].freeze

        private

        def timeline_classes(orientation: :vertical)
          track = orientation.to_sym == :horizontal ? TRACK_HORIZONTAL : TRACK_VERTICAL
          { classes: klasses(track) }
        end

        def timeline_item_classes(orientation: :vertical)
          item = orientation.to_sym == :horizontal ? ITEM_HORIZONTAL : ITEM_VERTICAL
          { classes: klasses(item) }
        end

        def timeline_item_indicator_classes(type: :dot, orientation: :vertical)
          base = if orientation.to_sym == :horizontal
                   type.to_sym == :icon ? ITEM_INDICATOR_ICON_HORIZONTAL : ITEM_INDICATOR_DOT_HORIZONTAL
                 else
                   type.to_sym == :icon ? ITEM_INDICATOR_ICON : ITEM_INDICATOR_DOT
                 end
          { classes: klasses(base) }
        end

        def timeline_item_time_classes(type: :default)
          base = type.to_sym == :badge ? ITEM_TIME_BADGE : ITEM_TIME
          { classes: klasses(base) }
        end

        def timeline_item_title_classes
          { classes: klasses(ITEM_TITLE) }
        end

        def timeline_item_heading_classes
          { classes: klasses(ITEM_HEADING) }
        end

        def timeline_item_trigger_classes
          { classes: klasses(ITEM_TRIGGER) }
        end

        def timeline_item_description_classes
          { classes: klasses(ITEM_DESCRIPTION) }
        end

        def timeline_item_detail_classes
          { classes: klasses(ITEM_DETAIL) }
        end

        def timeline_item_actions_classes
          { classes: klasses(ITEM_ACTIONS) }
        end

        def timeline_item_connector_classes
          { classes: klasses(ITEM_CONNECTOR_HORIZONTAL) }
        end

        def timeline_item_content_classes
          { classes: klasses(ITEM_CONTENT_HORIZONTAL) }
        end

        def timeline_track_line_classes
          { classes: klasses(TRACK_LINE_VERTICAL) }
        end

        def timeline_item_indicator_icon_slot_classes
          { classes: klasses(ITEM_INDICATOR_ICON_SLOT) }
        end
      end
    end
  end
end
