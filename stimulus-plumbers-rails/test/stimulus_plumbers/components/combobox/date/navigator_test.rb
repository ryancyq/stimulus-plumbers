# frozen_string_literal: true

require "test_helper"

class ComboboxDateNavigatorTest < ActionView::TestCase
  def navigator(**kwargs)
    StimulusPlumbers::Components::Combobox::Date::Navigator.new(self).render(**kwargs)
  end

  def test_renders_button
    assert_includes navigator, "<button"
  end

  def test_passes_data_attributes
    html = navigator(data: { "combobox-date-target" => "previous" })

    assert_includes html, 'data-combobox-date-target="previous"'
  end

  def test_merges_custom_class
    html = navigator(class: "nav-btn")

    assert_includes html, "nav-btn"
  end

  def test_renders_no_icon_by_default
    refute_includes navigator, "<svg"
  end

  def test_renders_icon_when_provided
    assert_css parse_html(navigator(icon: "arrow-left")), "button span"
  end
end
