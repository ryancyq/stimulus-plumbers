# frozen_string_literal: true

require "test_helper"

class ComboboxDatetimeTest < ActionView::TestCase
  OVERNIGHT = { min: "2026-11-03T22:00", max: "2026-11-04T02:00" }.freeze

  def render_datetime(**opts)
    parse_html(
      StimulusPlumbers::Components::Combobox::Datetime.new(self).render(
        id: "booking", name: "booking[at]", label: "Booking", **opts
      )
    )
  end

  def test_the_input_is_a_read_only_combobox_opening_a_dialog_named_after_the_field
    doc = render_datetime
    input = doc.at_css("input#booking")

    assert_equal "combobox", input["role"]
    assert input["readonly"]
    assert_equal "booking_popover", input["aria-controls"]
    assert_equal "Choose Booking", doc.at_css("#booking_popover")["aria-label"]
    assert_equal "Choose date and time", render_datetime(label: nil).at_css("[role='dialog']")["aria-label"]
  end

  def test_a_value_fills_the_input_and_the_submitted_date_time
    doc = render_datetime(value: "2026-11-03T22:15")

    assert_equal "2026-11-03T22:15", doc.at_css("input#booking")["value"]
    assert_css doc, "input[type='hidden'][name='booking[at]'][value='2026-11-03T22:15']"
  end

  def test_a_value_that_is_not_a_date_time_key_shows_as_typed_and_selects_nothing
    doc = render_datetime(value: "tonight")

    assert_equal "tonight", doc.at_css("input#booking")["value"]
    assert_no_css doc, "[role='option'][aria-selected='true']"
    assert_nil doc.at_css("[data-controller='calendar']")["data-calendar-selected-value"]
  end

  def test_the_root_wires_the_calendar_columns_and_formatter
    root = render_datetime.at_css("[data-controller]")

    assert_equal "popover combobox-datetime input-formatter", root["data-controller"]
    assert_equal "calendar:changed->combobox-datetime#onDateChange " \
                 "popover:before-open->combobox-datetime#onOpening popover:opened->combobox-datetime#onOpened " \
                 "popover:closed->combobox-datetime#onClosed focusout->combobox-datetime#onFocusout " \
                 "mousedown->combobox-datetime#onMousedown click->combobox-datetime#onClick " \
                 "combobox-datetime:changed->input-formatter#onChange",
                 root["data-action"]
    assert_equal "datetime", root["data-input-formatter-format-value"]
  end

  def test_the_root_carries_min_max_and_the_daily_window
    root = render_datetime(**OVERNIGHT, time: { min: "09:00", max: "23:00", step: 15 }).at_css("[data-controller]")

    assert_equal "2026-11-03T22:00", root["data-combobox-datetime-min-value"]
    assert_equal "2026-11-04T02:00", root["data-combobox-datetime-max-value"]
    assert_equal "09:00", root["data-combobox-datetime-time-min-value"]
    assert_equal "23:00", root["data-combobox-datetime-time-max-value"]
    assert_equal "15", root["data-combobox-datetime-step-value"]
  end

  def test_the_panel_restores_on_escape_and_holds_the_calendar_then_the_columns
    panel = render_datetime.at_css("#booking_popover")

    assert_equal "keydown.esc->combobox-datetime#onEscape", panel["data-action"]
    assert_equal(
      %w[calendar hour minute meridiem],
      panel.css("[data-combobox-datetime-target]").map { |part| part["data-combobox-datetime-target"] }
    )
  end

  def test_the_calendar_offers_the_dates_of_min_and_max_and_the_date_rules
    calendar = render_datetime(value: "2026-11-03T22:15", **OVERNIGHT, disabled_weekdays: [0], calendar: { today: "2026-11-01" })
               .at_css("[data-controller='calendar']")

    assert_equal "2026-11-03", calendar["data-calendar-selected-value"]
    assert_equal "2026-11-03", calendar["data-calendar-min-value"]
    assert_equal "2026-11-04", calendar["data-calendar-max-value"]
    assert_equal "[0]", calendar["data-calendar-disabled-weekdays-value"]
    assert_equal "2026-11-01", calendar["data-calendar-today-value"]
  end

  def test_a_boundary_date_with_no_time_left_is_unavailable
    calendar = render_datetime(min: "2026-11-03T18:00", time: { max: "17:00" }).at_css("[data-controller='calendar']")

    assert_equal '["2026-11-03"]', calendar["data-calendar-disabled-dates-value"]
  end

  def test_the_columns_offer_the_chosen_dates_times
    doc = render_datetime(value: "2026-11-03T22:15", **OVERNIGHT, format: { hourCycle: "h23" })

    assert_equal %w[22 23], available(doc, "Hour")
    assert_equal %w[00 01 02],
                 available(render_datetime(value: "2026-11-04T01:00", **OVERNIGHT, format: { hourCycle: "h23" }), "Hour")
  end

  def test_a_wrapped_daily_window_is_cut_off_at_min_on_its_date
    night = { min: "22:00", max: "02:00" }
    doc = render_datetime(value: "2026-11-03T23:00", min: "2026-11-03T01:00", time: night, format: { hourCycle: "h23" })

    assert_equal %w[01 02 22 23], available(doc, "Hour")
  end

  def test_the_columns_offer_the_daily_window_before_a_date_is_chosen
    doc = render_datetime(**OVERNIGHT, time: { min: "21:00", max: "23:00" }, format: { hourCycle: "h23" })

    assert_equal %w[21 22 23], available(doc, "Hour")
  end

  def test_unusable_options_raise
    assert_raises(ArgumentError) { render_datetime(min: "2026-11-04T02:00", max: "2026-11-03T22:00") }
    error = assert_raises(ArgumentError) { render_datetime(time: { step: 45 }) }

    assert_match(%r{\Atime\.step }, error.message)
  end

  def test_each_part_is_styled_from_the_theme
    parts = %i[combobox_datetime_popover combobox_datetime combobox_time combobox_time_drum]
    original = StimulusPlumbers.config.theme.current
    StimulusPlumbers.config.theme.use(key_theme(parts))
    doc = render_datetime

    parts.each { |key| assert doc.at_css(".sp-#{key}"), "#{key} is unstyled" }
  ensure
    StimulusPlumbers.config.theme.use(original)
  end

  def available(doc, column)
    doc.css("[aria-label='#{column}'] [role='option']:not([aria-disabled='true'])").map(&:text)
  end
end
