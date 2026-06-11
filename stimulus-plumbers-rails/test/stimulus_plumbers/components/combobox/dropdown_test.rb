# frozen_string_literal: true

require "test_helper"

class ComboboxDropdownTest < ActionView::TestCase
  def render_dropdown(**opts)
    StimulusPlumbers::Components::Combobox::Dropdown.new(self).render(**opts)
  end

  def test_renders_options
    doc = parse_html(render_dropdown(options: [["Canada", "ca"], ["United States", "us"]]))

    assert_css doc, "li[role='option'][data-value='ca']"
    assert_css doc, "li[role='option'][data-value='us']"
  end

  def test_marks_matching_value_as_selected
    doc = parse_html(render_dropdown(options: [["Canada", "ca"], ["United States", "us"]], value: "ca"))

    assert_css doc, "li[data-value='ca'][aria-selected='true']"
    assert_css doc, "li[data-value='us'][aria-selected='false']"
  end

  def test_renders_empty_listbox_when_no_options
    doc = parse_html(render_dropdown)

    assert_css doc, "ul[role='listbox']"
    assert_no_css doc, "li[role='option']"
  end

  def test_panel_is_the_listbox
    doc = parse_html(render_dropdown(panel_attrs: { id: "p1" }, options: [%w[Canada ca]]))

    assert_css doc, "ul#p1[role='listbox'][data-combobox-dropdown-target='listbox']"
  end

  def test_variant_metadata
    meta = StimulusPlumbers::Components::Combobox::Dropdown::Metadata

    assert_equal "listbox", meta.haspopup
    assert_equal "chevron-down", meta.trigger_icon
    assert_equal "p1", meta.popup_id_for("p1")
    assert_empty meta.stimulus_data("p1", {})
  end
end
