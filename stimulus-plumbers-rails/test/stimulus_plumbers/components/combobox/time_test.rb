# frozen_string_literal: true

require "test_helper"

class ComboboxTimeTest < ActionView::TestCase
  def render_time(**opts)
    parse_html(
      StimulusPlumbers::Components::Combobox::Time.new(self).render(
        id: "meeting", name: "event[meeting]", label: "Meeting", **opts
      )
    )
  end

  def test_the_input_is_a_read_only_combobox_opening_a_dialog
    input = render_time.at_css("input#meeting")

    assert_equal "combobox", input["role"]
    assert input["readonly"]
    assert_equal "Meeting", input["aria-label"]
    assert_equal "dialog", input["aria-haspopup"]
    assert_equal "meeting_popover", input["aria-controls"]
  end

  def test_a_time_value_fills_the_input_and_the_submitted_time
    doc = render_time(value: Time.utc(2026, 9, 15, 9, 5))

    assert_equal "09:05", doc.at_css("input#meeting")["value"]
    assert_css doc, "input[type='hidden'][name='event[meeting]'][value='09:05']"
  end

  def test_a_value_that_is_not_a_time_shows_as_typed_and_selects_nothing
    doc = render_time(value: "noonish")

    assert_equal "noonish", doc.at_css("input#meeting")["value"]
    assert_no_css doc, "[aria-selected='true']"
  end

  def test_the_popover_is_a_dialog_named_after_the_field
    panel = render_time.at_css("#meeting_popover")

    assert_equal "dialog", panel["role"]
    assert_equal "Choose Meeting", panel["aria-label"]
    assert_equal "Choose time", render_time(label: nil).at_css("[role='dialog']")["aria-label"]
  end

  def test_twelve_hour_columns_choose_the_hour_minute_and_meridiem
    doc = render_time(value: "14:30")

    assert_equal(%w[Hour Minute AM/PM], doc.css("[role='listbox']").map { |column| column["aria-label"] })
    assert_equal (1..12).map(&:to_s), doc.css("#meeting_popover [aria-label='Hour'] [role='option']").map(&:text)
    assert_chosen doc, "Hour", "2"
    assert_chosen doc, "Minute", "30"
    assert_chosen doc, "AM/PM", "PM"
  end

  def test_midnight_is_twelve_am
    doc = render_time(value: "00:15")

    assert_chosen doc, "Hour", "12"
    assert_chosen doc, "AM/PM", "AM"
  end

  def test_a_24_hour_cycle_has_no_meridiem_column
    doc = render_time(value: "09:05", format: { hourCycle: "h23" })

    assert_no_css doc, "[aria-label='AM/PM']"
    assert_equal 24, doc.css("[aria-label='Hour'] [role='option']").size
    assert_chosen doc, "Hour", "09"
    assert_no_css render_time(format: { hour12: false }), "[aria-label='AM/PM']"
  end

  def test_step_sets_the_minute_interval
    doc = render_time(value: "14:45", step: 15)

    assert_equal %w[00 15 30 45], doc.css("[aria-label='Minute'] [role='option']").map(&:text)
    assert_chosen doc, "Minute", "45"
  end

  def test_a_minute_off_the_step_chooses_no_minute_and_keeps_the_value
    doc = render_time(value: "14:58", step: 15)

    assert_chosen doc, "Hour", "2"
    assert_no_css doc, "[aria-label='Minute'][aria-activedescendant], [aria-label='Minute'] [aria-selected='true']"
    assert_equal "14:58", doc.at_css("input[type='hidden']")["value"]
  end

  def test_a_value_that_is_not_a_time_key_shows_as_typed
    doc = render_time(value: "9:30")

    assert_equal "9:30", doc.at_css("input#meeting")["value"]
    assert_no_css doc, "[aria-selected='true']"
  end

  def test_step_must_divide_an_hour
    error = assert_raises(ArgumentError) { render_time(step: 45) }

    assert_equal "step must be one of 1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60", error.message
  end

  def test_min_and_max_must_be_time_keys
    assert_raises(ArgumentError) { render_time(min: "9:00") }
  end

  def test_min_and_max_must_leave_a_time_on_the_step
    error = assert_raises(ArgumentError) { render_time(min: "09:05", max: "09:10", step: 15) }

    assert_equal "min and max leave no time on the step", error.message
  end

  def test_the_root_carries_min_max_and_step
    root = render_time(min: "09:00", max: "17:00", step: 15).at_css("[data-controller]")

    assert_equal "09:00", root["data-combobox-time-min-value"]
    assert_equal "17:00", root["data-combobox-time-max-value"]
    assert_equal "15", root["data-combobox-time-step-value"]
    assert_nil render_time.at_css("[data-controller]")["data-combobox-time-min-value"]
  end

  def test_hours_outside_min_and_max_are_unavailable
    doc = render_time(min: "09:00", max: "17:00", format: { hourCycle: "h23" })

    assert_equal %w[09 10 11 12 13 14 15 16 17], available(doc, "Hour")
    assert_equal 60, available(doc, "Minute").size
  end

  def test_a_min_after_max_wraps_past_midnight
    doc = render_time(min: "22:00", max: "01:00", format: { hourCycle: "h23" })

    assert_equal %w[00 01 22 23], available(doc, "Hour")
  end

  def test_a_window_that_wraps_past_midnight_limits_twelve_hour_columns_by_the_meridiem
    doc = render_time(value: "23:30", min: "22:00", max: "01:00")

    assert_equal %w[10 11], available(doc, "Hour")
    assert_equal %w[AM PM], available(doc, "AM/PM")
  end

  def test_the_value_limits_the_hours_by_its_meridiem_and_the_minutes_by_its_hour
    doc = render_time(value: "13:00", max: "13:00", step: 30)

    assert_equal %w[1 12], available(doc, "Hour")
    assert_equal %w[00], available(doc, "Minute")
    assert_equal %w[AM PM], available(doc, "AM/PM")
  end

  def test_a_meridiem_with_no_available_time_is_unavailable
    assert_equal %w[PM], available(render_time(min: "13:00"), "AM/PM")
  end

  def test_an_unavailable_value_stays_chosen
    doc = render_time(value: "14:30", max: "14:00", format: { hourCycle: "h23" })

    assert_chosen doc, "Minute", "30"
    assert_equal "true", doc.at_css("[aria-label='Minute'] [aria-selected='true']")["aria-disabled"]
  end

  def test_columns_are_focusable_and_wired_to_the_controller
    column = render_time.at_css("[aria-label='Hour']")

    assert_equal "0", column["tabindex"]
    assert_equal "keydown->combobox-time#onNavigate click->combobox-time#onSelect", column["data-action"]
  end

  def test_format_defaults_to_the_current_locale_and_a_12_hour_cycle
    assert_equal({ "hourCycle" => "h12", "locale" => "en" }, format_options)
    assert_equal({ "hourCycle" => "h23", "locale" => "ja" }, format_options(format: { hourCycle: "h23", locale: "ja" }))
  end

  def test_a_format_without_to_h_passes_as_is_with_12_hour_columns
    doc = render_time(format: :h24)

    assert_equal "\"h24\"", doc.at_css("[data-controller]")["data-input-formatter-options-value"]
    assert_css doc, "[aria-label='AM/PM']"
  end

  def test_meridiem_labels_fall_back_to_rails_i18n
    locales = I18n.available_locales
    I18n.available_locales = locales + [:fr]
    I18n.backend.store_translations(:fr, time: { am: "matin", pm: "soir" })
    doc = I18n.with_locale(:fr) { render_time }

    assert_equal %w[matin soir], doc.css("[data-combobox-time-target='meridiem'] [role='option']").map(&:text)
  ensure
    I18n.available_locales = locales
  end

  def test_the_root_wires_the_columns_to_the_field_and_the_formatter
    root = render_time.at_css("[data-controller]")

    assert_equal "popover combobox-time input-formatter", root["data-controller"]
    assert_equal "popover:before-open->combobox-time#onOpening popover:opened->combobox-time#onOpened " \
                 "popover:closed->combobox-time#onClosed focusout->combobox-time#onFocusout " \
                 "mousedown->combobox-time#onMousedown click->combobox-time#onClick " \
                 "combobox-time:changed->input-formatter#onChange",
                 root["data-action"]
    assert_equal "time", root["data-input-formatter-format-value"]
  end

  def test_the_trailing_icon_is_a_decorative_clock
    icons = render_time.css("[aria-hidden='true']").reject { |icon| icon.ancestors("[role='dialog']").any? }

    assert_equal 1, icons.size
  end

  def test_each_part_is_styled_from_the_theme
    parts = %i[combobox combobox_trigger combobox_time_popover combobox_time combobox_time_drum combobox_option]
    original = StimulusPlumbers.config.theme.current
    StimulusPlumbers.config.theme.use(key_theme(parts))
    doc = render_time

    parts.each { |key| assert doc.at_css(".sp-#{key}"), "#{key} is unstyled" }
  ensure
    StimulusPlumbers.config.theme.use(original)
  end

  def assert_chosen(doc, column, label)
    chosen = doc.css("[aria-label='#{column}'] [aria-selected='true']")

    assert_equal [label], chosen.map(&:text)
    assert_equal chosen.first["id"], doc.at_css("[aria-label='#{column}']")["aria-activedescendant"]
  end

  def available(doc, column)
    doc.css("[aria-label='#{column}'] [role='option']:not([aria-disabled='true'])").map(&:text)
  end

  def format_options(**opts)
    JSON.parse(render_time(**opts).at_css("[data-controller]")["data-input-formatter-options-value"])
  end
end
