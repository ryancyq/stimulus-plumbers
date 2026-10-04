# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Modal
        WRAPPER = %w[inline-block].freeze

        SURFACE = %w[
          sp-modal m-0 box-border w-screen h-screen supports-[height:100dvh]:h-[100dvh] max-w-none max-h-none p-0
          open:grid
          grid-rows-[auto_minmax(0,1fr)_auto] overflow-hidden border-0
          bg-(--sp-color-bg) text-(--sp-color-fg) shadow-(--sp-shadow-xl)
          sm:m-auto sm:w-full sm:h-fit
          sm:max-h-[calc(100vh-var(--sp-space-6))]
          sm:supports-[height:100dvh]:max-h-[calc(100dvh-var(--sp-space-6))]
          sm:rounded-(--sp-radius-lg)
        ].freeze

        BACKDROP = %w[
          backdrop:bg-(--sp-modal-backdrop) backdrop:backdrop-blur-[2px]
        ].freeze

        HEADER = %w[
          row-start-1
          flex shrink-0 items-center gap-(--sp-space-3)
          ps-[max(var(--sp-space-6),env(safe-area-inset-left))]
          pe-[max(var(--sp-space-6),env(safe-area-inset-right))]
          pt-[max(var(--sp-space-6),env(safe-area-inset-top))] pb-(--sp-space-3)
        ].freeze

        TITLE = %w[
          min-w-0 text-(length:--sp-text-lg) font-semibold text-(--sp-color-fg)
        ].freeze

        BODY = %w[
          row-start-2 min-h-0 overflow-y-auto overscroll-contain
          ps-[max(var(--sp-space-6),env(safe-area-inset-left))]
          pe-[max(var(--sp-space-6),env(safe-area-inset-right))] py-(--sp-space-3)
          first:pt-[max(var(--sp-space-6),env(safe-area-inset-top))]
          last:pb-[max(var(--sp-space-6),env(safe-area-inset-bottom))]
        ].freeze

        TURBO_FRAME = %w[
          row-span-3 min-h-0 grid grid-rows-subgrid overflow-hidden
          [&>header]:row-start-1 [&>header]:flex [&>header]:shrink-0 [&>header]:items-center [&>header]:gap-(--sp-space-3)
          [&>header]:ps-[max(var(--sp-space-6),env(safe-area-inset-left))]
          [&>header]:pe-[max(var(--sp-space-6),env(safe-area-inset-right))]
          [&>header]:pt-[max(var(--sp-space-6),env(safe-area-inset-top))] [&>header]:pb-(--sp-space-3)
          [&>header>h2]:min-w-0 [&>header>h2]:text-(length:--sp-text-lg)
          [&>header>h2]:font-semibold [&>header>h2]:text-(--sp-color-fg)
          [&>div]:row-start-2 [&>div]:min-h-0 [&>div]:overflow-y-auto [&>div]:overscroll-contain
          [&>div]:ps-[max(var(--sp-space-6),env(safe-area-inset-left))]
          [&>div]:pe-[max(var(--sp-space-6),env(safe-area-inset-right))] [&>div]:py-(--sp-space-3)
          [&>div:first-child]:pt-[max(var(--sp-space-6),env(safe-area-inset-top))]
          [&>div:last-child]:pb-[max(var(--sp-space-6),env(safe-area-inset-bottom))]
          [&>footer]:row-start-3 [&>footer]:flex [&>footer]:shrink-0 [&>footer]:flex-wrap
          [&>footer]:items-center [&>footer]:justify-end [&>footer]:gap-(--sp-space-2)
          [&>footer]:ps-[max(var(--sp-space-6),env(safe-area-inset-left))]
          [&>footer]:pe-[max(var(--sp-space-6),env(safe-area-inset-right))]
          [&>footer]:pt-(--sp-space-3) [&>footer]:pb-[max(var(--sp-space-6),env(safe-area-inset-bottom))]
          sm:[&>footer]:rounded-b-(--sp-radius-lg)
        ].freeze

        FOOTER = %w[
          row-start-3
          flex shrink-0 flex-wrap items-center justify-end gap-(--sp-space-2)
          ps-[max(var(--sp-space-6),env(safe-area-inset-left))]
          pe-[max(var(--sp-space-6),env(safe-area-inset-right))]
          pt-(--sp-space-3) pb-[max(var(--sp-space-6),env(safe-area-inset-bottom))]
          sm:rounded-b-(--sp-radius-lg)
        ].freeze

        SIZES = {
          sm: %w[sm:max-w-(--sp-modal-size-sm)].freeze,
          md: %w[sm:max-w-(--sp-modal-size-md)].freeze,
          lg: %w[sm:max-w-(--sp-modal-size-lg)].freeze,
          xl: %w[sm:max-w-(--sp-modal-size-xl)].freeze
        }.freeze

        private

        def modal_wrapper_classes
          { classes: klasses(*WRAPPER) }
        end

        def modal_classes(size: :md)
          { classes: klasses(*SURFACE, *SIZES.fetch(size, SIZES[:md])) }
        end

        def modal_backdrop_classes
          { classes: klasses(*BACKDROP) }
        end

        def modal_header_classes
          { classes: klasses(*HEADER) }
        end

        def modal_title_classes
          { classes: klasses(*TITLE) }
        end

        def modal_body_classes
          { classes: klasses(*BODY) }
        end

        def modal_turbo_classes
          { classes: klasses(*TURBO_FRAME) }
        end

        def modal_footer_classes
          { classes: klasses(*FOOTER) }
        end
      end
    end
  end
end
