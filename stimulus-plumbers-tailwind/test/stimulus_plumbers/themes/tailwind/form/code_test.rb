# frozen_string_literal: true

require "test_helper"

class TailwindThemeFormCodeTest < Minitest::Test
  include ThemeAssertions

  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def test_code_field_shows_the_focus_ring_while_focused_within
    result = classes_for(:form_field_input_code)

    assert_includes result, "focus-within:ring-(length:--sp-focus-ring-width)"
    assert_includes result, "focus-within:ring-(--sp-focus-ring-color)"
  end

  def test_code_field_with_an_error_takes_the_error_focus_ring
    assert_includes classes_for(:form_field_input_code, error: true), "focus-within:ring-(--sp-color-error)"
  end

  def test_code_cells_are_bordered_boxes_that_show_the_caret
    result = classes_for(:form_field_input_code_cell)

    assert_includes result, "border-(--sp-color-muted-fg)"
    assert_includes result, "data-[caret]:ring-1"
    assert_includes result, "data-[caret]:ring-(--sp-color-primary)"
  end

  def test_code_cell_with_an_error_has_the_error_border_and_caret
    result = classes_for(:form_field_input_code_cell, error: true)

    assert_includes result, "border-(--sp-color-error)"
    assert_includes result, "data-[caret]:ring-(--sp-color-error)"
  end

  def test_code_overlay_remains_present_but_invisible
    result = classes_for(:form_field_input_code_overlay)

    assert_includes result, "opacity-0"
    refute_includes result, "hidden"
  end

  def test_code_separator_is_muted
    assert_includes classes_for(:form_field_input_code_separator), "text-(--sp-color-muted-fg)"
  end
end
