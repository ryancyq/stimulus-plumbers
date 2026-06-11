# frozen_string_literal: true

require "test_helper"

class ComboboxDateTest < ActionView::TestCase
  def render_date(**opts)
    StimulusPlumbers::Components::Combobox::Date.new(self).render(**opts)
  end

  def test_renders_wrapper_div
    assert_css parse_html(render_date), "div"
  end

  def test_has_combobox_date_controller
    assert_css parse_html(render_date), "[data-controller~='combobox-date']"
  end

  def test_renders_navigation
    assert_css parse_html(render_date), "nav"
  end

  def test_renders_calendar_grid
    assert_css parse_html(render_date), "[role='grid']"
  end

  def test_sets_date_value_when_given
    assert_css parse_html(render_date(value: "2024-06-15")),
               "[data-combobox-date-date-value='2024-06-15']"
  end

  def test_no_date_value_attribute_when_nil
    assert_no_css parse_html(render_date(value: nil)), "[data-combobox-date-date-value]"
  end

  def test_calendar_id_for_derives_from_panel_id
    assert_equal "my_panel_calendar",
                 StimulusPlumbers::Components::Combobox::Date.calendar_id_for("my_panel")
  end

  def test_calendar_id_for_with_nil_returns_fallback
    assert_equal "calendar",
                 StimulusPlumbers::Components::Combobox::Date.calendar_id_for(nil)
  end

  def test_outlet_selector_matches_calendar_id_when_panel_id_given
    doc             = parse_html(render_date(panel_attrs: { id: "test_panel" }))
    date_controller = doc.at_css("[data-controller~='combobox-date']")
    calendar        = doc.at_css("[data-controller~='calendar-month']")

    assert_equal "#test_panel_calendar", date_controller["data-combobox-date-calendar-month-outlet"]
    assert_equal "test_panel_calendar",  calendar["id"]
  end

  def test_variant_metadata
    meta = StimulusPlumbers::Components::Combobox::Date::Metadata

    assert_equal "dialog", meta.haspopup
    assert_equal "calendar", meta.trigger_icon
    assert_equal "date", meta.stimulus_data("p1", {})[:input_formatter_format_value]
  end
end
