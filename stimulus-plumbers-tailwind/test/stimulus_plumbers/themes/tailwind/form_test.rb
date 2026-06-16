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

  def test_form_submit_returns_empty_hash
    result = @theme.resolve(:form_submit)

    assert_equal({}, result)
  end

  def test_form_submit_returns_empty_hash_with_type_and_variant
    result = @theme.resolve(:form_submit, type: :default, variant: :primary)

    assert_equal({}, result)
  end

  def test_form_group_error_does_not_change_layout_classes
    stacked         = classes_for(:form_group, layout: :stacked)
    stacked_error   = classes_for(:form_group, layout: :stacked, error: true)
    inline          = classes_for(:form_group, layout: :inline)
    inline_error    = classes_for(:form_group, layout: :inline, error: true)

    assert_equal stacked, stacked_error
    assert_equal inline, inline_error
  end
end
