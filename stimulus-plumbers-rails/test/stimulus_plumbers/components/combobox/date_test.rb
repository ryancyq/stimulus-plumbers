# frozen_string_literal: true

require "test_helper"

class ComboboxDateTest < ActionView::TestCase
  def render_date(**opts)
    parse_html(
      StimulusPlumbers::Components::Combobox::Date.new(self).render(
        id: "birthday", name: "person[birthday]", label: "Birthday", calendar: { today: Date.new(2026, 9, 10) }, **opts
      )
    )
  end

  def test_the_input_is_a_read_only_combobox_opening_a_dialog
    input = render_date.at_css("input#birthday")

    assert_equal "combobox", input["role"]
    assert input["readonly"]
    assert_equal "none", input["inputmode"]
    assert_equal "Birthday", input["aria-label"]
    assert_equal "dialog", input["aria-haspopup"]
    assert_equal "false", input["aria-expanded"]
    assert_equal "birthday_popover", input["aria-controls"]
  end

  def test_a_date_value_fills_the_input_and_the_submitted_date_key
    doc = render_date(value: Date.new(2026, 9, 15))

    assert_equal "2026-09-15", doc.at_css("input#birthday")["value"]
    assert_css doc, "input[type='hidden'][name='person[birthday]'][value='2026-09-15']"
  end

  def test_a_value_that_is_not_a_date_shows_as_typed_and_selects_nothing
    doc = render_date(value: "next tuesday")

    assert_equal "next tuesday", doc.at_css("input#birthday")["value"]
    assert_nil doc.at_css("[data-controller='calendar']")["data-calendar-selected-value"]
  end

  def test_the_popover_is_a_dialog_named_after_the_field
    panel = render_date.at_css("#birthday_popover")

    assert_equal "auto", panel["popover"]
    assert_equal "dialog", panel["role"]
    assert_equal "Choose Birthday", panel["aria-label"]
  end

  def test_an_external_label_names_the_input_and_the_popover
    doc = render_date(label: nil, labelledby: "dob_label")

    assert_equal "dob_label", doc.at_css("input#birthday")["aria-labelledby"]
    assert_equal "dob_label", doc.at_css("#birthday_popover")["aria-labelledby"]
  end

  def test_the_popover_holds_a_selectable_calendar_with_min
    calendar = render_date(value: Date.new(2026, 9, 15), min: "2026-09-03")
               .at_css("#birthday_popover div#birthday_calendar[data-controller='calendar']")

    assert_equal "2026-09-15", calendar["data-calendar-selected-value"]
    assert_equal "true", calendar["data-calendar-selectable-value"]
    assert_equal "2026-09-03", calendar["data-calendar-min-value"]
  end

  def test_the_calendar_shows_the_selected_month_unless_told_otherwise
    displayed = ->(**opts) { render_date(**opts).at_css("[data-controller='calendar']")["data-calendar-displayed-value"] }

    assert_equal "2026-09-15", displayed.call(value: Date.new(2026, 9, 15))
    assert_equal "2026-12-01", displayed.call(value: Date.new(2026, 9, 15), calendar: { displayed: "2026-12-01" })
  end

  def test_focus_click_and_keys_open_the_popover
    actions = render_date.at_css("input#birthday")["data-action"].split

    assert_includes actions, "focus->popover#onFocus"
    assert_includes actions, "click->popover#onOpen"
    assert_includes actions, "keydown->combobox-date#onKeydown"
  end

  def test_open_on_focus_can_be_turned_off
    actions = render_date(open_on_focus: false).at_css("input#birthday")["data-action"].split

    assert_not_includes actions, "focus->popover#onFocus"
    assert_includes actions, "click->popover#onOpen"
  end

  def test_format_is_passed_to_the_formatter_with_the_current_locale_unless_given
    options = format_options(format: { month: "long", day: "numeric", year: "numeric" })

    assert_equal({ "locale" => "en", "month" => "long", "day" => "numeric", "year" => "numeric" }, options)
    assert_equal "ja", format_options(format: { locale: "ja" })["locale"]
  end

  def test_the_root_wires_the_calendar_to_the_field_and_the_formatter
    root = render_date.at_css("[data-controller]")

    assert_equal "popover combobox-date input-formatter", root["data-controller"]
    assert_equal "calendar:changed->combobox-date#onChange focusout->combobox-date#onFocusout " \
                 "mousedown->combobox-date#onMousedown click->combobox-date#onClick " \
                 "combobox-date:changed->input-formatter#onChange",
                 root["data-action"]
  end

  def test_icons_are_decorative
    doc = render_date(icon_leading: "user")

    icons = doc.css("[aria-hidden='true']").reject { |icon| icon.ancestors("[role='dialog']").any? }

    assert_equal 2, icons.size
  end

  def test_each_part_is_styled_from_the_theme
    parts = %i[combobox combobox_trigger_group combobox_trigger combobox_trigger_icon combobox_date_popover]
    original = StimulusPlumbers.config.theme.current
    StimulusPlumbers.config.theme.use(key_theme(parts))
    doc = render_date

    parts.each { |key| assert doc.at_css(".sp-#{key}"), "#{key} is unstyled" }
  ensure
    StimulusPlumbers.config.theme.use(original)
  end

  def format_options(**opts)
    JSON.parse(render_date(**opts).at_css("[data-controller]")["data-input-formatter-options-value"])
  end
end
