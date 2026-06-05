# frozen_string_literal: true

require "test_helper"

class ComboboxDateNavigationTest < ActionView::TestCase
  def navigation(**kwargs)
    StimulusPlumbers::Components::Combobox::Date::Navigation.new(self).render(
      step:                "month",
      stimulus_controller: "combobox-date",
      date:                Date.new(2026, 6, 1),
      **kwargs
    )
  end

  def test_renders_nav_element
    assert_includes navigation, "<nav"
  end

  def test_nav_has_aria_label
    assert_css parse_html(navigation), "nav[aria-label='Date picker navigation']"
  end

  def test_renders_three_buttons
    assert_equal 3, parse_html(navigation).css("button").length
  end

  def test_previous_button_has_aria_label
    assert_css parse_html(navigation), "button[aria-label='Previous Month']"
  end

  def test_next_button_has_aria_label
    assert_css parse_html(navigation), "button[aria-label='Next Month']"
  end

  def test_previous_button_contains_icon
    assert_css parse_html(navigation), "button[aria-label='Previous Month'] span"
  end

  def test_next_button_contains_icon
    assert_css parse_html(navigation), "button[aria-label='Next Month'] span"
  end

  def test_view_title_button_has_drillup_action
    doc = parse_html(navigation)
    btn = doc.at_css("button[data-combobox-date-target='viewTitle']")

    assert btn, "expected viewTitle button"
    assert_equal "click->combobox-date#zoomOut", btn["data-action"]
  end

  def test_view_title_shows_month_and_year_in_month_view
    doc = parse_html(navigation(view: "month", date: Date.new(2026, 6, 1)))
    btn = doc.at_css("button[data-combobox-date-target='viewTitle']")

    assert_match(%r{June 2026}, btn.text)
  end

  def test_view_title_shows_year_in_year_view
    doc = parse_html(navigation(view: "year", date: Date.new(2026, 6, 1), step: "year"))
    btn = doc.at_css("button[data-combobox-date-target='viewTitle']")

    assert_equal "2026", btn.text.strip
  end

  def test_view_title_shows_decade_in_decade_view
    doc = parse_html(navigation(view: "decade", date: Date.new(2026, 6, 1), step: "decade"))
    btn = doc.at_css("button[data-combobox-date-target='viewTitle']")

    assert_equal "2020–2029", btn.text.strip
  end

  def test_prev_label_changes_with_step
    doc = parse_html(navigation(step: "year"))

    assert_css doc, "button[aria-label='Previous Year']"
  end

  def test_next_label_changes_with_step
    doc = parse_html(navigation(step: "year"))

    assert_css doc, "button[aria-label='Next Year']"
  end
end
