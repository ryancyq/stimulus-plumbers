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
    assert_includes result, "[&:is(button)]:cursor-pointer"
    assert_includes result, "[&:is(button)]:hover:bg-(--sp-color-muted)"
  end

  def test_calendar_day_includes_today_aria_variant
    assert_includes classes_for(:calendar_day), "aria-[current=date]:font-bold"
  end

  def test_calendar_day_includes_selected_aria_variants
    result = classes_for(:calendar_day)

    assert_includes result, "aria-selected:bg-(--sp-color-primary)"
    assert_includes result, "aria-selected:text-(--sp-color-primary-fg)"
  end

  def test_calendar_day_includes_aria_hidden_pointer_events_none
    assert_includes classes_for(:calendar_day), "aria-[hidden=true]:pointer-events-none"
  end

  def test_calendar_day_includes_aria_disabled_variants
    result = classes_for(:calendar_day)

    assert_includes result, "aria-[disabled=true]:text-(--sp-color-muted-fg)"
    assert_includes result, "aria-[disabled=true]:pointer-events-none"
  end

  def test_calendar_day_includes_native_disabled_variants
    result = classes_for(:calendar_day)

    assert_includes result, "disabled:text-(--sp-color-muted-fg)"
    assert_includes result, "disabled:pointer-events-none"
  end

  def test_calendar_day_outside_includes_muted_text
    result = classes_for(:calendar_day, outside: true)

    assert_includes result, "text-(--sp-color-muted-fg)"
  end

  def test_calendar_day_non_outside_excludes_explicit_muted_text
    inside_result = classes_for(:calendar_day)
    outside_result = classes_for(:calendar_day, outside: true)

    refute_equal inside_result, outside_result
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

  def test_calendar_row_returns_contents_display
    assert_includes classes_for(:calendar_row), "contents"
  end

  def test_calendar_months_of_year_returns_contents_display
    assert_includes classes_for(:calendar_months_of_year), "contents"
  end

  def test_calendar_years_of_decade_returns_contents_display
    assert_includes classes_for(:calendar_years_of_decade), "contents"
  end

  def test_calendar_quarter_grid_includes_grid_classes
    result = classes_for(:calendar_quarter_grid)

    assert_includes result, "grid"
    assert_includes result, "grid-cols-4"
    assert_includes result, "gap-(--sp-space-1)"
  end

  def test_calendar_month_returns_a_classes_string
    result = classes_for(:calendar_month)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_calendar_month_includes_base_classes
    result = classes_for(:calendar_month)

    assert_includes result, "flex"
    assert_includes result, "cursor-pointer"
    assert_includes result, "h-10"
  end

  def test_calendar_month_includes_aria_current_variant
    assert_includes classes_for(:calendar_month), "aria-[current=month]:font-bold"
  end

  def test_calendar_month_includes_selected_aria_variants
    result = classes_for(:calendar_month)

    assert_includes result, "aria-selected:bg-(--sp-color-primary)"
    assert_includes result, "aria-selected:text-(--sp-color-primary-fg)"
  end

  def test_calendar_month_includes_aria_disabled_variants
    result = classes_for(:calendar_month)

    assert_includes result, "aria-[disabled=true]:text-(--sp-color-muted-fg)"
    assert_includes result, "aria-[disabled=true]:pointer-events-none"
    assert_includes result, "aria-[disabled=true]:hover:bg-transparent"
  end

  def test_calendar_year_returns_a_classes_string
    result = classes_for(:calendar_year)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_calendar_year_includes_base_classes
    result = classes_for(:calendar_year)

    assert_includes result, "flex"
    assert_includes result, "cursor-pointer"
    assert_includes result, "h-10"
  end

  def test_calendar_year_includes_aria_current_variant
    assert_includes classes_for(:calendar_year), "aria-[current=year]:font-bold"
  end

  def test_calendar_year_includes_selected_aria_variants
    result = classes_for(:calendar_year)

    assert_includes result, "aria-selected:bg-(--sp-color-primary)"
    assert_includes result, "aria-selected:text-(--sp-color-primary-fg)"
  end

  def test_calendar_year_includes_aria_disabled_variants
    result = classes_for(:calendar_year)

    assert_includes result, "aria-[disabled=true]:text-(--sp-color-muted-fg)"
    assert_includes result, "aria-[disabled=true]:pointer-events-none"
    assert_includes result, "aria-[disabled=true]:hover:bg-transparent"
  end

  # ── sp_calendar ──

  def test_calendar_status_is_visually_hidden
    assert_includes classes_for(:calendar_status), "sr-only"
  end

  def test_calendar_heading_is_semibold_foreground_text
    result = classes_for(:calendar_heading)

    assert_includes result, "font-semibold"
    assert_includes result, "text-(--sp-color-fg)"
  end

  def test_calendar_navigation_and_dates_are_at_least_one_day_cell
    %i[calendar_navigation calendar_date].each do |key|
      assert_includes classes_for(key), "min-h-(--sp-calendar-day-size)"
      assert_includes classes_for(key), "min-w-(--sp-calendar-day-size)"
    end
  end

  def test_calendar_navigation_and_dates_show_the_focus_ring
    %i[calendar_navigation calendar_date].each do |key|
      assert_includes classes_for(key), "focus-visible:outline-(--sp-focus-ring-color)"
    end
  end

  def test_calendar_grid_dims_while_its_frame_loads
    assert_includes classes_for(:calendar_grid), "[[aria-busy=true]_&]:opacity-60"
  end

  def test_calendar_weekdays_are_muted
    assert_includes classes_for(:calendar_weekday), "text-(--sp-color-muted-fg)"
  end

  def test_calendar_today_is_bold_and_underlined
    result = classes_for(:calendar_date)

    assert_includes result, "aria-[current=date]:font-bold"
    assert_includes result, "aria-[current=date]:underline"
  end

  def test_calendar_selected_date_is_filled_with_primary
    result = classes_for(:calendar_date)

    assert_includes result, "[[aria-selected=true]>&]:bg-(--sp-color-primary)"
    assert_includes result, "[[aria-selected=true]>&]:text-(--sp-color-primary-fg)"
  end

  def test_calendar_selected_date_keeps_a_fill_in_forced_colors
    result = classes_for(:calendar_date)

    assert_includes result, "forced-colors:[[aria-selected=true]>&]:forced-color-adjust-none"
    assert_includes result, "forced-colors:[[aria-selected=true]>&]:bg-[Highlight]"
  end

  def test_calendar_adjacent_dates_are_muted
    assert_includes classes_for(:calendar_date), "data-outside:text-(--sp-color-muted-fg)"
  end

  def test_calendar_unavailable_dates_are_faded_and_struck_through
    result = classes_for(:calendar_date)

    assert_includes result, "aria-disabled:opacity-40"
    assert_includes result, "aria-disabled:line-through"
  end
end
