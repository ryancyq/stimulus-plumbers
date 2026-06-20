# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Timeline
        # Vertical track: border on start side of <ol>
        TRACK_VERTICAL   = %w[relative border-s border-(--sp-color-border)].freeze
        # Horizontal track: border on top of <ol>
        TRACK_HORIZONTAL = %w[flex border-t border-(--sp-color-border)].freeze

        # Vertical item: offset from track line
        ITEM_VERTICAL    = %w[relative mb-10 ms-6].freeze
        # Horizontal item: offset from track line
        ITEM_HORIZONTAL  = %w[relative flex-1 pt-4].freeze

        # Dot indicator: small circle positioned over the track
        DOT_BASE = %w[
          absolute -start-3 mt-1.5 size-3 rounded-full
          border border-(--sp-color-surface)
          bg-(--sp-color-surface-muted)
        ].freeze

        # Icon indicator: larger circle with icon inside
        ICON_BASE = %w[
          absolute -start-4 flex size-7 items-center justify-center rounded-full
          bg-(--sp-color-primary) text-(--sp-color-on-primary)
        ].freeze

        TIME_BASE        = %w[mb-1 block text-sm leading-none text-(--sp-color-text-muted)].freeze
        TITLE_BASE       = %w[mb-1 text-base font-semibold text-(--sp-color-text)].freeze
        TRIGGER_WRAPPER  = %w[mb-1].freeze
        TRIGGER_BASE     = %w[
          w-full text-left text-base font-semibold
          text-(--sp-color-text)
          hover:text-(--sp-color-primary)
          focus-visible:outline-none focus-visible:ring-2
          focus-visible:ring-(--sp-color-ring) focus-visible:rounded-sm
        ].freeze
        DESCRIPTION_BASE = %w[text-sm text-(--sp-color-text-muted)].freeze
        DETAIL_BASE      = %w[mt-2 text-sm text-(--sp-color-text-muted)].freeze
        ACTIONS_BASE     = %w[mt-3 flex flex-wrap items-center gap-2].freeze

        private

        def timeline_classes(orientation: :vertical)
          track = orientation.to_sym == :horizontal ? TRACK_HORIZONTAL : TRACK_VERTICAL
          { classes: klasses(track) }
        end

        def timeline_item_classes(orientation: :vertical)
          item = orientation.to_sym == :horizontal ? ITEM_HORIZONTAL : ITEM_VERTICAL
          { classes: klasses(item) }
        end

        def timeline_indicator_classes(type: :dot)
          base = type.to_sym == :icon ? ICON_BASE : DOT_BASE
          { classes: klasses(base) }
        end

        def timeline_time_classes        = { classes: klasses(TIME_BASE) }
        def timeline_title_classes       = { classes: klasses(TITLE_BASE) }
        def timeline_trigger_wrapper_classes = { classes: klasses(TRIGGER_WRAPPER) }
        def timeline_trigger_classes     = { classes: klasses(TRIGGER_BASE) }
        def timeline_description_classes = { classes: klasses(DESCRIPTION_BASE) }
        def timeline_detail_classes      = { classes: klasses(DETAIL_BASE) }
        def timeline_actions_classes     = { classes: klasses(ACTIONS_BASE) }
      end
    end
  end
end
