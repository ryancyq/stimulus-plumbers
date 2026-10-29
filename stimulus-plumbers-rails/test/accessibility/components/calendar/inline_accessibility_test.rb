# frozen_string_literal: true

require_relative "../../application_accessibility_test_case"

class CalendarInlineAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/calendar/inline#{query}"
  end

  def query
    ""
  end

  def test_every_section_passes_wcag
    assert_sections_accessible
  end

  def test_next_month_replaces_only_that_calendar
    find("#calendar-month [data-navigation='next']").execute_script("this.focus()")
    press :enter

    within("#calendar-month") { assert_selector "h2", text: "October 2026" }
    within("#calendar-other-months") { assert_selector "h2", text: "September 2026" }
    assert_current_path "/components/calendar/inline#{query}"
    assert_equal "Next month", evaluate_script("document.activeElement.getAttribute('aria-label')")
    assert_accessible context: "#calendar-month"
  end

  def test_page_down_moves_focus_into_the_next_month_and_announces_it
    focus_day "2026-09-15"
    press :page_down

    within("#calendar-month") { assert_selector "h2", text: "October 2026" }
    assert_focused_day "2026-10-15"
    assert_selector "#calendar-month [role='status']", text: "October 2026"
  end

  def test_opening_a_year_from_the_keyboard_focuses_its_months
    find("#calendar-decade [data-date='2024-01-01']").execute_script("this.focus()")
    press :enter

    within("#calendar-decade") { assert_selector "h2", text: "2024" }
    assert_equal "2024-01-01", evaluate_script("document.activeElement.dataset.date")
  end

  def test_zooming_out_shows_the_months_of_the_year
    within("#calendar-month") { click_on "Choose month" }

    within("#calendar-month") { assert_selector "h2", text: "2026" }
    assert_accessible context: "#calendar-month"
  end

  def test_arrow_keys_move_focus_without_selecting
    focus_day "2026-09-15"
    press :right
    press :down

    assert_focused_day "2026-09-23"
    assert_selector "#calendar-month td[aria-selected='true'] [data-date='2026-09-15']"
  end

  def test_enter_selects_the_focused_day
    focus_day "2026-09-15"
    press :right, :enter

    assert_selector "#calendar-month td[aria-selected='true'] [data-date='2026-09-16']"
    assert_accessible context: "#calendar-month"
  end

  def test_clicking_a_day_selects_it
    find("#calendar-month [data-date='2026-09-17']").click

    assert_selector "#calendar-month td[aria-selected='true'] [data-date='2026-09-17']"
  end

  def test_tab_enters_the_grid_on_the_selected_day
    find("#calendar-month [data-navigation='previous']").execute_script("this.focus()")
    press :tab, :tab, :tab, :tab

    assert_focused_day "2026-09-15"
  end

  def test_tab_leaves_the_grid_after_one_stop
    focus_day "2026-09-15"
    press :tab

    assert_nil evaluate_script("document.activeElement.closest('#calendar-month table')")
  end

  def test_a_month_in_the_year_view_opens_that_month
    find("#calendar-year [aria-label='March 2026']").click

    within("#calendar-year") { assert_selector "h2", text: "March 2026" }
  end

  private

  def focus_day(date)
    find("#calendar-month [data-date='#{date}']").execute_script("this.focus()")
  end

  def assert_focused_day(date)
    assert_equal date, evaluate_script("document.activeElement.dataset.date")
  end
end

class CalendarInlineTurboAccessibilityTest < CalendarInlineAccessibilityTest
  def query
    "?navigation=turbo"
  end
end

class CalendarModeParityTest < ApplicationAccessibilityTestCase
  SIGNATURE = <<~JS
    [...document.querySelectorAll("[data-controller~='calendar']")].map((container) => {
      const grid = container.querySelector("[role='grid']");
      const heading = document.getElementById(grid.getAttribute("aria-labelledby"));
      const cells = [...grid.querySelectorAll("td")].map((cell) => {
        const control = cell.querySelector("[data-date]");
        return [cell.getAttribute("role"), cell.getAttribute("aria-selected"), control && [
          control.dataset.date, control.dataset.calendarTarget, control.tabIndex, control.dataset.outside ?? null,
          control.getAttribute("aria-disabled"), control.getAttribute("aria-current"), control.hasAttribute("aria-label")
        ]];
      });
      const headers = [...grid.querySelectorAll("th")].map((th) => [th.scope, th.abbr !== ""]);
      return [container.id, grid.dataset.view, grid.dataset.displayed, grid.getAttribute("aria-readonly"), heading.id,
              heading.textContent !== "", headers, cells];
    })
  JS

  def test_stimulus_and_turbo_render_the_same_grids
    visit "/components/calendar/inline"

    assert_selector "#calendar-decade [data-date]"
    stimulus = evaluate_script(SIGNATURE)

    visit "/components/calendar/inline?navigation=turbo"
    turbo = evaluate_script(SIGNATURE)

    assert_equal 4, turbo.size
    assert_equal turbo, stimulus
  end
end
