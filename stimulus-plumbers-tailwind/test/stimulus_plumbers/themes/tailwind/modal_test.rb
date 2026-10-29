# frozen_string_literal: true

require "test_helper"

class TailwindThemeModalTest < Minitest::Test
  include ThemeAssertions

  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def test_surface_is_a_raised_panel_that_animates_with_the_packaged_modal_states
    result = classes_for(:modal)

    assert_includes result, "sp-modal"
    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "text-(--sp-color-fg)"
    assert_includes result, "shadow-(--sp-shadow-xl)"
    assert_includes result, "sm:rounded-(--sp-radius-lg)"
  end

  def test_surface_size_tokens_change_the_desktop_maximum
    assert_includes classes_for(:modal, size: :sm), "sm:max-w-(--sp-modal-size-sm)"
    assert_includes classes_for(:modal, size: :md), "sm:max-w-(--sp-modal-size-md)"
    refute_includes classes_for(:modal, size: :sm), "sm:max-w-(--sp-modal-size-md)"
  end

  def test_backdrop_dims_and_blurs_the_page
    result = classes_for(:modal_backdrop)

    assert_includes result, "backdrop:bg-(--sp-modal-backdrop)"
    assert_includes result, "backdrop:backdrop-blur-[2px]"
  end

  def test_title_is_semibold
    assert_includes classes_for(:modal_title), "font-semibold"
  end

  def test_modal_turbo_frame_title_is_semibold
    assert_includes classes_for(:modal_turbo), "[&>header>h2]:font-semibold"
  end
end
