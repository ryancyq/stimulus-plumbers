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

  def test_haspopup_is_listbox
    assert_equal "listbox", StimulusPlumbers::Components::Combobox.variant(:typeahead).haspopup
  end

  def test_popup_id_points_at_the_listbox
    assert_equal "p1_listbox", StimulusPlumbers::Components::Combobox.variant(:typeahead).popup_id_for("p1")
  end
end
