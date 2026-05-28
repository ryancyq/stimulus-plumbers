# frozen_string_literal: true

require "test_helper"

class ComboboxDropdownTest < ActionView::TestCase
  def render_dropdown(**opts)
    StimulusPlumbers::Components::Combobox::Dropdown.new(self).render(**opts)
  end

  # ── options ───────────────────────────────────────────────────────────────

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

  def test_renders_nothing_when_no_options
    assert_empty render_dropdown.strip
  end

  # ── default_opts ──────────────────────────────────────────────────────────

  def test_default_opts_panel_tag_is_ul
    assert_equal :ul, StimulusPlumbers::Components::Combobox::Dropdown.default_opts.dig(:popover, :tag)
  end

  def test_default_opts_panel_role_is_listbox
    assert_equal "listbox", StimulusPlumbers::Components::Combobox::Dropdown.default_opts.dig(:popover, :role)
  end

  def test_default_opts_panel_haspopup_is_listbox
    assert_equal "listbox", StimulusPlumbers::Components::Combobox::Dropdown.default_opts.dig(:popover, :haspopup)
  end
end
