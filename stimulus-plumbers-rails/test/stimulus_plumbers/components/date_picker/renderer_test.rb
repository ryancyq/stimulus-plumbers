# frozen_string_literal: true

require "test_helper"

class DatePickerRendererTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::DatePicker::Renderer.new(self)
  end

  # datepicker root
  def test_renders_datepicker_and_popover_controllers
    assert_includes renderer.render, 'data-controller="datepicker popover"'
  end

  def test_wires_datepicker_outlet_to_calendar_month_when_calendar_id_given
    html = renderer.render(calendar_id: "start_date")

    assert_includes html, 'data-datepicker-calendar-month-outlet="#start_date"'
    assert_includes html, 'id="start_date"'
  end

  def test_omits_outlet_when_no_calendar_id
    assert_not_includes renderer.render, "calendar-month-outlet"
  end

  def test_wires_calendar_month_observer_selected_to_datepicker_selected
    assert_includes renderer.render, "calendar-month-observer:selected-&gt;datepicker#selected"
  end

  def test_wires_calendar_month_observer_selected_to_popover_hide
    assert_includes renderer.render, "calendar-month-observer:selected-&gt;popover#hide"
  end

  # inputs
  def test_renders_display_input
    assert_includes renderer.render, 'data-datepicker-target="display"'
  end

  def test_display_input_has_aria_label
    assert_includes renderer.render, 'aria-label="Date"'
  end

  def test_display_input_has_combobox_role
    assert_includes renderer.render, 'role="combobox"'
  end

  def test_display_input_has_haspopup_dialog
    assert_includes renderer.render, 'aria-haspopup="dialog"'
  end

  def test_display_input_aria_controls_references_dialog
    html = renderer.render(calendar_dialog_id: "my_dialog")
    assert_includes html, 'aria-controls="my_dialog"'
    assert_includes html, 'id="my_dialog"'
  end

  def test_display_input_is_popover_activator
    assert_includes renderer.render, 'data-popover-target="activator"'
  end

  def test_display_input_opens_popover_on_focus
    assert_includes renderer.render, "focus-&gt;popover#show"
  end

  def test_display_input_opens_popover_on_click
    assert_includes renderer.render, "click-&gt;popover#show"
  end

  def test_renders_hidden_input
    html = renderer.render

    assert_includes html, 'type="hidden"'
    assert_includes html, 'data-datepicker-target="input"'
  end

  # popover
  def test_popover_is_popover_content_target
    assert_includes renderer.render, 'data-popover-target="content"'
  end

  def test_popover_has_dialog_role
    assert_includes renderer.render, 'role="dialog"'
  end

  def test_popover_is_hidden_by_default
    assert_includes renderer.render, "hidden"
  end

  # navigation
  def test_renders_navigation
    assert_includes renderer.render, "<nav"
  end

  def test_navigation_renders_previous_button
    assert_includes renderer.render, 'data-datepicker-target="previous"'
  end

  def test_navigation_renders_next_button
    assert_includes renderer.render, 'data-datepicker-target="next"'
  end

  def test_navigation_renders_day_target
    assert_includes renderer.render, 'data-datepicker-target="day"'
  end

  def test_navigation_renders_month_target
    assert_includes renderer.render, 'data-datepicker-target="month"'
  end

  def test_navigation_renders_year_target
    assert_includes renderer.render, 'data-datepicker-target="year"'
  end

  # calendar grid
  def test_renders_calendar_month_controller
    assert_match(%r{data-controller="[^"]*calendar-month[^"]*"}, renderer.render)
  end

  def test_renders_calendar_month_observer_controller
    assert_match(%r{data-controller="[^"]*calendar-month-observer[^"]*"}, renderer.render)
  end

  # html options
  def test_passes_html_options
    html = renderer.render(id: "my-picker", class: "cal")

    assert_includes html, 'id="my-picker"'
    assert_includes html, "cal"
  end

  def test_merges_data_attributes
    html = renderer.render(data: { foo: "bar" })

    assert_includes html, 'data-controller="datepicker popover"'
    assert_includes html, "data-foo"
  end
end
