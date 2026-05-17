# frozen_string_literal: true

require "test_helper"

class DatePickerNavigationTest < ActionView::TestCase
  def navigation(**kwargs)
    StimulusPlumbers::Components::DatePicker::Navigation.new(self).render(
      step:                "month",
      stimulus_controller: "combobox-date",
      **kwargs
    )
  end

  def test_renders_nav_element
    assert_includes navigation, "<nav"
  end

  def test_nav_has_aria_label
    assert_css parse_html(navigation), "nav[aria-label='DatePicker Navigation']"
  end

  def test_renders_five_buttons
    assert_equal 5, parse_html(navigation).css("button").length
  end

  def test_previous_button_has_aria_label
    assert_css parse_html(navigation), "button[aria-label='Previous Month']"
  end

  def test_next_button_has_aria_label
    assert_css parse_html(navigation), "button[aria-label='Next Month']"
  end
end
