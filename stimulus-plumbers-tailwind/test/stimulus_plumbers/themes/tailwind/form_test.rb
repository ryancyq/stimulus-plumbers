# frozen_string_literal: true

require "test_helper"

class TailwindThemeFormTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes]
  end

  # :form_group

  def test_form_group_includes_base_flex_classes
    result = classes_for(:form_group)

    assert_includes result, "flex"
    assert_includes result, "gap-(--sp-space-1)"
    assert_includes result, "mb-(--sp-space-3)"
  end

  def test_form_group_stacked_layout_includes_flex_col
    assert_includes classes_for(:form_group, layout: :stacked), "flex-col"
  end

  def test_form_group_stacked_layout_excludes_inline_classes
    result = classes_for(:form_group, layout: :stacked)

    refute_includes result, "flex-row"
    refute_includes result, "items-center"
  end

  def test_form_group_inline_layout_includes_row_and_alignment_classes
    result = classes_for(:form_group, layout: :inline)

    assert_includes result, "flex-row"
    assert_includes result, "items-center"
  end

  def test_form_group_inline_layout_excludes_flex_col
    refute_includes classes_for(:form_group, layout: :inline), "flex-col"
  end

  # :form_submit

  def test_form_submit_default_type_includes_button_layout_classes
    assert_includes classes_for(:form_submit), "inline-flex"
  end

  def test_form_submit_default_type_includes_primary_variant
    assert_includes classes_for(:form_submit), "[--btn-bg:var(--sp-color-primary)]"
  end

  def test_form_submit_outline_type_includes_button_layout_classes
    assert_includes classes_for(:form_submit, type: :outline), "inline-flex"
  end

  def test_form_submit_outline_type_excludes_solid_text
    refute_includes classes_for(:form_submit, type: :outline), "text-(--btn-fg)"
  end
end
