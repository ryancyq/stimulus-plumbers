# frozen_string_literal: true

require "test_helper"

class CalendarTurboHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::CalendarTurboHelper

  # ── rendering ─────────────────────────────────────────────────────────────

  def test_renders_html
    assert_css parse_html(sp_calendar_month_turbo), "div"
  end

  # ── date ──────────────────────────────────────────────────────────────────

  def test_passes_date_to_renderer
    # Feb 2026 starts on Sunday with 28 days — no padding cells
    doc = parse_html(sp_calendar_month_turbo(date: Date.new(2026, 2, 1)))

    assert_equal 28, doc.css("[role='gridcell']").length
  end

  def test_passes_today_to_renderer
    assert_css parse_html(sp_calendar_month_turbo(date: Date.new(2026, 4, 1), today: Date.new(2026, 4, 10))),
               "[aria-current='date']"
  end

  # ── options ───────────────────────────────────────────────────────────────

  def test_passes_selectable_to_renderer
    assert_css parse_html(sp_calendar_month_turbo(selectable: true)), "button"
  end

  def test_passes_selected_date_to_renderer
    doc = parse_html(
      sp_calendar_month_turbo(
        date:          Date.new(2026, 4, 1),
        selectable:    true,
        selected_date: Date.new(2026, 4, 10)
      )
    )

    assert_css doc, "[aria-selected='true']"
  end

  def test_passes_show_other_months_to_renderer
    # Apr 2026 has padding days; with show_other_months they become aria-disabled gridcells
    assert_css parse_html(sp_calendar_month_turbo(date: Date.new(2026, 4, 1), show_other_months: true)),
               "[aria-disabled='true']"
  end

  # ── html options ──────────────────────────────────────────────────────────

  def test_passes_html_options_to_renderer
    doc = parse_html(sp_calendar_month_turbo(class: "my-cal", data: { foo: "bar" }))

    assert_css doc, ".my-cal"
    assert_css doc, "[data-foo='bar']"
  end
end
