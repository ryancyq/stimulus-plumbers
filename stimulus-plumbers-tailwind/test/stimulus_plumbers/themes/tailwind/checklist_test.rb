# frozen_string_literal: true

require "test_helper"

class TailwindThemeChecklistTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes]
  end

  def test_checklist_returns_a_classes_string
    result = classes_for(:checklist)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_checklist_item_input_is_a_real_checkbox_control
    assert_includes classes_for(:checklist_item_input), "cursor-pointer"
  end

  def test_checklist_item_input_dims_when_disabled
    assert_includes classes_for(:checklist_item_input), "disabled:opacity-50"
  end

  def test_checklist_item_input_checked_color_matches_theme_primary
    assert_includes classes_for(:checklist_item_input), "[accent-color:var(--sp-color-primary)]"
  end

  def test_checklist_item_title_strikes_through_when_checked
    assert_includes classes_for(:checklist_item_title), "group-has-checked"
    assert_includes classes_for(:checklist_item_title), "line-through"
  end

  def test_checklist_item_content_uses_flex_col
    result = classes_for(:checklist_item_content)

    assert_includes result, "flex-col"
  end

  def test_checklist_item_title_uses_muted_color_when_checked
    assert_includes classes_for(:checklist_item_title), "--sp-color-muted-fg"
  end

  def test_resolving_with_no_kwargs_does_not_raise
    # Regression guard for the arity bug found in list_item_title_classes/list_item_description_classes
    assert_silent { @theme.resolve(:checklist_item_title) }
    assert_silent { @theme.resolve(:checklist_item_description) }
  end

  def test_checklist_item_row_dims_hover_when_disabled
    assert_includes classes_for(:checklist_item), "has-disabled"
  end
end
