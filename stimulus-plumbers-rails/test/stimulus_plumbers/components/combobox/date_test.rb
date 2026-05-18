# frozen_string_literal: true

require "test_helper"

class ComboboxDateTest < ActionView::TestCase
  def render_date(**opts)
    StimulusPlumbers::Components::Combobox::Date.new(self).render(**opts)
  end

  def test_renders_wrapper_div
    html = render_date

    assert_includes html, "<div"
  end

  def test_has_combobox_date_controller
    html = render_date

    assert_includes html, "combobox-date"
  end

  def test_renders_navigation
    doc = parse_html(render_date)

    assert_css doc, "nav"
  end

  def test_renders_calendar_grid
    doc = parse_html(render_date)

    assert_css doc, "[role='grid']"
  end

  def test_sets_date_value_when_given
    html = render_date(value: "2024-06-15")

    assert_includes html, "2024-06-15"
  end

  def test_no_date_value_when_nil
    html = render_date(value: nil)

    refute_includes html, "date-value"
  end
end
