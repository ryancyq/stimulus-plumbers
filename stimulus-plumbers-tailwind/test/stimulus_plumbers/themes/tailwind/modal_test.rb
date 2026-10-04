# frozen_string_literal: true

require "test_helper"

class TailwindThemeModalTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes]
  end

  def test_wrapper_is_inline_block
    assert_includes classes_for(:modal_wrapper), "inline-block"
  end

  def test_surface_uses_packaged_modal_animation_states
    result = classes_for(:modal)

    assert_includes result, "sp-modal"
    assert_includes result, "open:grid"
    assert_includes result, "w-screen"
    assert_includes result, "h-screen"
    assert_includes result, "supports-[height:100dvh]:h-[100dvh]"
    assert_includes result, "max-w-none"
    assert_includes result, "border-0"
    assert_includes result, "p-0"
    refute_includes result, "opacity-0"
    refute_includes result, "open:opacity-100"
    refute_includes result, "translate-y-(--sp-modal-enter-offset)"
    refute_includes result, "open:translate-y-0"
  end

  def test_surface_is_centered_and_bounded_on_desktop
    result = classes_for(:modal)

    assert_includes result, "sm:m-auto"
    assert_includes result, "sm:w-full"
    assert_includes result, "sm:h-fit"
    assert_includes result, "sm:max-h-[calc(100vh-var(--sp-space-6))]"
    assert_includes result, "sm:supports-[height:100dvh]:max-h-[calc(100dvh-var(--sp-space-6))]"
  end

  def test_surface_size_tokens_change_the_desktop_maximum
    assert_includes classes_for(:modal, size: :sm), "sm:max-w-(--sp-modal-size-sm)"
    assert_includes classes_for(:modal, size: :md), "sm:max-w-(--sp-modal-size-md)"
    refute_includes classes_for(:modal, size: :sm), "sm:max-w-(--sp-modal-size-md)"
  end

  def test_backdrop_uses_themeable_backdrop_tokens
    result = classes_for(:modal_backdrop)

    assert_includes result, "backdrop:bg-(--sp-modal-backdrop)"
    assert_includes result, "backdrop:backdrop-blur-[2px]"
  end

  def test_body_is_the_scrollable_region
    result = classes_for(:modal_body)

    assert_includes result, "row-start-2"
    assert_includes result, "min-h-0"
    assert_includes result, "overflow-y-auto"
    assert_includes result, "overscroll-contain"
  end

  def test_optional_local_regions_keep_their_grid_rows
    assert_includes classes_for(:modal_header), "row-start-1"
    assert_includes classes_for(:modal_body), "row-start-2"
    assert_includes classes_for(:modal_footer), "row-start-3"
  end

  def test_body_adds_safe_area_insets_when_it_is_an_outer_region
    result = classes_for(:modal_body)

    assert_includes result, "first:pt-[max(var(--sp-space-6),env(safe-area-inset-top))]"
    assert_includes result, "last:pb-[max(var(--sp-space-6),env(safe-area-inset-bottom))]"
  end

  def test_footer_stays_outside_the_scrollable_region
    result = classes_for(:modal_footer)

    assert_includes result, "shrink-0"
    refute_includes result.split, "overflow-y-auto"
  end

  def test_modal_turbo_frame_has_three_rows_and_only_body_scrolls
    result = classes_for(:modal_turbo)

    assert_includes result, "row-span-3"
    assert_includes result, "min-h-0"
    assert_includes result, "grid-rows-subgrid"
    assert_includes result, "[&>header]:row-start-1"
    assert_includes result, "[&>div]:row-start-2"
    assert_includes result, "[&>div]:overflow-y-auto"
    assert_includes result, "[&>div:first-child]:pt-[max(var(--sp-space-6),env(safe-area-inset-top))]"
    assert_includes result, "[&>div:last-child]:pb-[max(var(--sp-space-6),env(safe-area-inset-bottom))]"
    assert_includes result, "[&>footer]:row-start-3"
    assert_includes result, "[&>header>h2]:font-semibold"
    assert_includes result, "[&>footer]:flex"
    refute_includes result.split, "overflow-y-auto"
  end

  def test_header_and_title_have_semantic_visual_styles
    assert_includes classes_for(:modal_header), "shrink-0"
    assert_includes classes_for(:modal_title), "font-semibold"
  end
end
