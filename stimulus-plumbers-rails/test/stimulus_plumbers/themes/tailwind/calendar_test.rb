# frozen_string_literal: true

require "test_helper"

class TailwindThemeCalendarTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes]
  end

  def test_calendar_day_returns_a_classes_string
    result = classes_for(:calendar_day)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_calendar_day_includes_base_day_classes
    result = classes_for(:calendar_day)

    assert_includes result, "flex"
    assert_includes result, "cursor-pointer"
  end

  def test_calendar_day_includes_font_bold_when_today
    assert_includes classes_for(:calendar_day, today: true), "font-bold"
  end

  def test_calendar_day_excludes_font_bold_when_not_today
    refute_includes classes_for(:calendar_day, today: false), "font-bold"
  end

  def test_calendar_day_includes_selected_classes_when_selected
    result = classes_for(:calendar_day, selected: true)

    assert_includes result, "bg-[--sp-color-primary]"
    assert_includes result, "text-[--sp-color-primary-fg]"
  end

  def test_calendar_day_excludes_selected_classes_when_not_selected
    refute_includes classes_for(:calendar_day, selected: false), "bg-[--sp-color-primary]"
  end

  def test_calendar_day_includes_outside_classes_when_outside_month
    result = classes_for(:calendar_day, outside: true)

    assert_includes result, "text-[--sp-color-muted-fg]"
    assert_includes result, "opacity-50"
  end

  def test_calendar_day_excludes_outside_classes_when_not_outside
    result = classes_for(:calendar_day, outside: false)

    refute_includes result, "text-[--sp-color-muted-fg]"
    refute_includes result, "opacity-50"
  end

  def test_calendar_includes_width_class
    assert_includes classes_for(:calendar), "w-full"
  end

  def test_calendar_days_of_week_includes_grid_classes
    result = classes_for(:calendar_days_of_week)

    assert_includes result, "grid"
    assert_includes result, "grid-cols-7"
  end

  def test_calendar_days_of_month_includes_grid_classes
    result = classes_for(:calendar_days_of_month)

    assert_includes result, "grid"
    assert_includes result, "grid-cols-7"
  end

  def test_calendar_navigation_includes_flex_classes
    result = classes_for(:calendar_navigation)

    assert_includes result, "flex"
    assert_includes result, "justify-between"
  end

  def test_calendar_navigation_navigator_includes_button_classes
    result = classes_for(:calendar_navigation_navigator)

    assert_includes result, "inline-flex"
    assert_includes result, "focus-visible:ring-2"
    assert_includes result, "disabled:opacity-50"
  end

  def test_calendar_navigation_navigator_icon_includes_size_class
    assert_includes classes_for(:calendar_navigation_navigator_icon), "size-4"
  end

  def test_calendar_week_returns_a_classes_string
    result = classes_for(:calendar_week)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_calendar_week_includes_contents_class
    assert_includes classes_for(:calendar_week), "contents"
  end
end
