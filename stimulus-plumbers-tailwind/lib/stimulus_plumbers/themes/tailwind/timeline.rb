# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Timeline
        TRACK_VERTICAL   = %w[relative border-s border-(--sp-color-border)].freeze
        TRACK_HORIZONTAL = %w[flex border-t border-(--sp-color-border)].freeze

        ITEM_VERTICAL    = %w[relative mb-10 ms-6].freeze
        ITEM_HORIZONTAL  = %w[relative flex-1 pt-4].freeze

        ITEM_INDICATOR_DOT = %w[
          absolute -start-3 mt-1.5 size-3 rounded-full
          border border-(--sp-color-surface)
          bg-(--sp-color-surface-muted)
        ].freeze

        ITEM_INDICATOR_ICON = %w[
          absolute -start-4 flex size-7 items-center justify-center rounded-full
          bg-(--sp-color-primary) text-(--sp-color-on-primary)
        ].freeze

        ITEM_TIME        = %w[mb-1 block text-sm leading-none text-(--sp-color-text-muted)].freeze
        ITEM_TITLE       = %w[mb-1 text-base font-semibold text-(--sp-color-text)].freeze
        ITEM_HEADING     = %w[mb-1].freeze
        ITEM_TRIGGER     = %w[
          w-full text-left text-base font-semibold
          text-(--sp-color-text)
          hover:text-(--sp-color-primary)
          focus-visible:outline-none focus-visible:ring-2
          focus-visible:ring-(--sp-color-ring) focus-visible:rounded-sm
        ].freeze
        ITEM_DESCRIPTION = %w[text-sm text-(--sp-color-text-muted)].freeze
        ITEM_DETAIL      = %w[mt-2 text-sm text-(--sp-color-text-muted)].freeze
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

        def timeline_item_indicator_classes(type: :dot)
          base = type.to_sym == :icon ? ITEM_INDICATOR_ICON : ITEM_INDICATOR_DOT
          { classes: klasses(base) }
        end

        def timeline_item_time_classes        = { classes: klasses(ITEM_TIME) }
        def timeline_item_title_classes       = { classes: klasses(ITEM_TITLE) }
        def timeline_item_heading_classes     = { classes: klasses(ITEM_HEADING) }
        def timeline_item_trigger_classes     = { classes: klasses(ITEM_TRIGGER) }
        def timeline_item_description_classes = { classes: klasses(ITEM_DESCRIPTION) }
        def timeline_item_detail_classes      = { classes: klasses(ITEM_DETAIL) }
        def timeline_item_actions_classes     = { classes: klasses(ITEM_ACTIONS) }
      end
    end
  end
end
