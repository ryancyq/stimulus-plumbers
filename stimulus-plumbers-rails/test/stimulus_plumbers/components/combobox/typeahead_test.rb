# frozen_string_literal: true

require "test_helper"

class ComboboxTypeaheadTest < ActionView::TestCase
  def render_typeahead(**opts)
    StimulusPlumbers::Components::Combobox::Typeahead.new(self).render(**opts)
  end

  def test_panel_wraps_a_listbox
    doc = parse_html(render_typeahead(panel_attrs: { id: "p1" }))

    assert_css doc, "div[data-controller~='combobox-dropdown'] > ul[role='listbox']"
  end

  def test_listbox_id_is_derived_from_panel_id
    listbox = parse_html(render_typeahead(panel_attrs: { id: "p1" })).at_css("ul[role='listbox']")

    assert_equal "p1_listbox", listbox["id"]
    assert_equal "listbox",    listbox["data-combobox-dropdown-target"]
  end

  def test_options_are_the_only_listbox_children
    doc = parse_html(render_typeahead(panel_attrs: { id: "p1" }, options: [%w[London lon]]))

    assert_css doc, "ul[role='listbox'] > li[role='option'][data-value='lon']"
    assert_no_css doc, "ul[role='listbox'] [role='status']"
    assert_no_css doc, "ul[role='listbox'] [aria-live]"
  end

  def test_loading_is_a_sibling_status_region_hidden_by_default
    doc = parse_html(render_typeahead(panel_attrs: { id: "p1" }))

    assert_css doc, "div[role='status'][hidden][data-combobox-dropdown-target='loading']"
    assert_no_css doc, "ul[role='listbox'] [data-combobox-dropdown-target='loading']"
  end

  def test_empty_is_a_sibling_status_region_hidden_by_default
    doc = parse_html(render_typeahead(panel_attrs: { id: "p1" }))

    assert_css doc, "div[role='status'][hidden][data-combobox-dropdown-target='empty']"
    assert_no_css doc, "ul[role='listbox'] [data-combobox-dropdown-target='empty']"
  end

  def test_empty_state_has_no_results_text
    assert_includes parse_html(render_typeahead).text, "No results"
  end

  def test_renders_options
    doc = parse_html(render_typeahead(options: [%w[London lon], %w[Paris par]]))

    assert_css doc, "li[data-value='lon']"
    assert_css doc, "li[data-value='par']"
  end

  def test_url_sets_combobox_dropdown_url_value_on_panel
    doc = parse_html(render_typeahead(panel_attrs: { id: "p1" }, url: "/search"))

    assert_css doc, "div[data-controller~='combobox-dropdown'][data-combobox-dropdown-url-value='/search']"
  end

  def test_variant_metadata
    meta = StimulusPlumbers::Components::Combobox::Typeahead::Metadata

    assert_equal "listbox", meta.haspopup
    assert_nil meta.trigger_icon
    assert_equal "p1_listbox", meta.popup_id_for("p1")
    refute meta.trigger_options[:readonly]
    assert_equal "list", meta.trigger_options.dig(:aria, :autocomplete)
  end

  def test_variant_dataset_wires_outlet
    data = StimulusPlumbers::Components::Combobox::Typeahead::Metadata.dataset("p1_popover", {})

    assert_equal "#p1_popover", data[:input_combobox_combobox_dropdown_outlet]
    assert_equal "input->input-combobox#onInput", data[:action]
  end
end
