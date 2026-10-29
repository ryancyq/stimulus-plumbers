# frozen_string_literal: true

require "test_helper"

class TailwindThemeButtonGroupTest < Minitest::Test
  include ThemeAssertions

  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def test_button_group_defaults_to_inline_layout
    result = classes_for(:button_group)

    assert_includes result, "inline-flex"
    assert_includes result, "shadow-(--sp-shadow-xs)"
  end

  def test_button_group_inline_lays_buttons_out_in_a_row
    result = classes_for(:button_group, layout: :inline)

    assert_includes result, "inline-flex"
    refute_includes result, "flex-col"
  end

  def test_button_group_inline_rounds_first_and_last_child
    result = classes_for(:button_group, layout: :inline)

    assert_includes result, "[&>*]:rounded-none"
    assert_includes result, "[&>*:first-child]:rounded-s-(--sp-radius-md)"
    assert_includes result, "[&>*:last-child]:rounded-e-(--sp-radius-md)"
  end

  def test_button_group_stacked_stacks_buttons_in_a_column
    result = classes_for(:button_group, layout: :stacked)

    assert_includes result, "flex-col"
    refute_includes result, "inline-flex"
  end

  def test_button_group_stacked_rounds_first_and_last_child
    result = classes_for(:button_group, layout: :stacked)

    assert_includes result, "[&>*]:rounded-none"
    assert_includes result, "[&>*:first-child]:rounded-t-(--sp-radius-md)"
    assert_includes result, "[&>*:last-child]:rounded-b-(--sp-radius-md)"
  end

  def test_button_group_stacked_does_not_include_inline_child_rounding
    result = classes_for(:button_group, layout: :stacked)

    refute_includes result, "[&>*:first-child]:rounded-s-(--sp-radius-md)"
    refute_includes result, "[&>*:last-child]:rounded-e-(--sp-radius-md)"
  end
end
