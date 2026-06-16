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

  def test_renders_calendar_month_grid
    assert_css parse_html(render_date), "[role='grid'][data-controller~='calendar-month']"
  end

  def test_renders_year_view_container
    doc     = parse_html(render_date(panel_attrs: { id: "test_panel" }))
    year_id = StimulusPlumbers::Components::Combobox::Date.year_id_for("test_panel")

    assert_css doc, "[role='grid'][data-controller='calendar-year'][id='#{year_id}']"
    assert_css doc, "[id='#{year_id}'][aria-label='Year view']"
    assert_css doc, "[id='#{year_id}'][hidden]"
    assert_css doc, "[id='#{year_id}'] [data-calendar-year-target='grid']"
  end

  def test_renders_decade_view_container
    doc       = parse_html(render_date(panel_attrs: { id: "test_panel" }))
    decade_id = StimulusPlumbers::Components::Combobox::Date.decade_id_for("test_panel")

    assert_css doc, "[role='grid'][data-controller='calendar-decade'][id='#{decade_id}']"
    assert_css doc, "[id='#{decade_id}'][aria-label='Decade view']"
    assert_css doc, "[id='#{decade_id}'][hidden]"
    assert_css doc, "[id='#{decade_id}'] [data-calendar-decade-target='grid']"
  end

  def test_sets_date_value_when_given
    assert_css parse_html(render_date(value: "2024-06-15")),
               "[data-combobox-date-date-value='2024-06-15']"
  end

  def test_no_date_value_attribute_when_nil
    assert_no_css parse_html(render_date(value: nil)), "[data-combobox-date-date-value]"
  end

  def test_month_id_for_derives_from_panel_id
    assert_equal "my_panel_calendar_month",
                 StimulusPlumbers::Components::Combobox::Date.month_id_for("my_panel")
  end

  def test_month_id_for_with_nil_returns_fallback
    assert_equal "calendar_month",
                 StimulusPlumbers::Components::Combobox::Date.month_id_for(nil)
  end

  def test_year_id_for_derives_from_panel_id
    assert_equal "my_panel_calendar_year",
                 StimulusPlumbers::Components::Combobox::Date.year_id_for("my_panel")
  end

  def test_decade_id_for_derives_from_panel_id
    assert_equal "my_panel_calendar_decade",
                 StimulusPlumbers::Components::Combobox::Date.decade_id_for("my_panel")
  end

  def test_outlet_selectors_match_view_ids_when_panel_id_given
    doc             = parse_html(render_date(panel_attrs: { id: "test_panel" }))
    date_controller = doc.at_css("[data-controller~='combobox-date']")
    calendar        = doc.at_css("[data-controller~='calendar-month']")

    assert_equal "#test_panel_calendar_month",   date_controller["data-combobox-date-calendar-month-outlet"]
    assert_equal "#test_panel_calendar_year",    date_controller["data-combobox-date-calendar-year-outlet"]
    assert_equal "#test_panel_calendar_decade",  date_controller["data-combobox-date-calendar-decade-outlet"]
    assert_equal "test_panel_calendar_month",    calendar["id"]
  end

  def test_variant_metadata
    meta = StimulusPlumbers::Components::Combobox::Date::Metadata

    assert_equal "dialog", meta.haspopup
    assert_equal "calendar", meta.trigger_icon
    assert_equal "date", meta.stimulus_data("p1", {})[:input_formatter_format_value]
  end
end
