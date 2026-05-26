# frozen_string_literal: true

require "test_helper"

class TailwindThemeInputGroupTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes]
  end

  # :input_group

  def test_input_group_includes_base_classes
    result = classes_for(:input_group)

    assert_includes result, "flex"
    assert_includes result, "items-center"
    assert_includes result, "rounded-(--sp-radius-md)"
    assert_includes result, "border"
  end

  def test_input_group_includes_default_border_when_no_error
    assert_includes classes_for(:input_group), "border-(--sp-color-muted-fg)"
  end

  def test_input_group_excludes_error_border_when_no_error
    refute_includes classes_for(:input_group), "border-(--sp-color-error)"
  end

  def test_input_group_includes_error_border_when_error
    assert_includes classes_for(:input_group, error: true), "border-(--sp-color-error)"
  end

  def test_input_group_excludes_default_border_when_error
    refute_includes classes_for(:input_group, error: true), "border-(--sp-color-muted-fg)"
  end
end
