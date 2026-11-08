# frozen_string_literal: true

require "test_helper"

class ComboboxTest < ActionView::TestCase
  OPTIONS = [%w[Singapore sg], ["Seoul", "se", { description: "Korea" }], ["Sydney", "sy", { disabled: true }]].freeze

  def render_dropdown(**kwargs)
    parse_html(StimulusPlumbers::Components::Combobox::Dropdown.new(self).render(id: "city", options: OPTIONS, **kwargs))
  end

  def render_typeahead(**kwargs)
    parse_html(StimulusPlumbers::Components::Combobox::Typeahead.new(self).render(id: "city", options: OPTIONS, **kwargs))
  end

  def test_container_wires_the_combobox_controller
    doc = render_dropdown

    assert_css doc, "div[data-controller='combobox'][data-combobox-mode-value='select_only']"
    assert_css doc, "div[data-action='mousedown->combobox#onMousedown click->combobox#onClick']"
  end

  def test_select_only_control_is_a_button
    control = render_dropdown.at_css("[role='combobox']")

    assert_equal "button", control.name
    assert_equal "button", control["type"]
    assert_equal "keydown->combobox#onKeydown", control["data-action"]
  end

  def test_editable_control_is_a_text_input_with_input_action
    control = render_typeahead.at_css("[role='combobox']")

    assert_equal "input", control.name
    assert_equal "off", control["autocomplete"]
    assert_includes control["data-action"], "input->combobox#onInput"
  end

  def test_control_references_the_listbox_and_starts_collapsed
    doc     = render_dropdown
    control = doc.at_css("[role='combobox']")

    assert_equal "false", control["aria-expanded"]
    assert_equal "city_popover_listbox", control["aria-controls"]
    assert_css doc, "ul#city_popover_listbox[role='listbox'][data-combobox-target='listbox']"
    assert_nil control["aria-haspopup"]
    assert_nil control["aria-activedescendant"]
  end

  def test_control_shows_the_selected_label
    doc = render_dropdown(value: "se")

    assert_equal "Seoul", doc.at_css("button[role='combobox']").text
    assert_equal "Seoul", render_typeahead(value: "se").at_css("input[role='combobox']")["value"]
  end

  def test_hidden_input_holds_name_and_value
    doc = render_dropdown(name: "trip[city]", value: "sg")

    assert_css doc, "input[type='hidden'][name='trip[city]'][value='sg'][data-combobox-target='input']"
  end

  def test_panel_is_a_manual_popover_owned_only_by_the_combobox
    panel = render_dropdown.at_css("#city_popover")

    assert_equal "manual", panel["popover"]
    assert_equal "panel", panel["data-combobox-target"]
    assert_nil panel["data-popover-target"]
  end

  def test_options_have_instance_unique_ids_and_selection
    doc = render_dropdown(value: "se")

    assert_css doc, "li#city_popover_listbox_option_1[role='option'][data-value='sg'][aria-selected='false']"
    assert_css doc, "li#city_popover_listbox_option_2[aria-selected='true']"
    assert_css doc, "li#city_popover_listbox_option_3[aria-disabled='true']"
  end

  def test_option_description_is_not_part_of_its_name
    option = render_dropdown.at_css("#city_popover_listbox_option_2")

    assert_equal "Seoul", option["data-label"]
    assert_equal "city_popover_listbox_option_2_label", option["aria-labelledby"]
    assert_equal "city_popover_listbox_option_2_description", option["aria-describedby"]
  end

  def test_groups_use_group_role_labelled_by_a_presentational_item
    doc = render_dropdown(options: [{ label: "Asia", options: [%w[Singapore sg]] }], value: "sg")

    assert_css doc, "ul[role='listbox'] > li[role='none'] > ul[role='group'][aria-labelledby='city_popover_listbox_group_1']"
    assert_css doc, "li#city_popover_listbox_group_1[role='none']", text: "Asia"
    assert_css doc, "ul[role='group'] > li#city_popover_listbox_option_1[aria-selected='true']"
    assert_equal "Singapore", doc.at_css("button[role='combobox']").text
  end

  def test_label_names_the_control_and_listbox
    doc = render_dropdown(label: "City")

    assert_equal "City", doc.at_css("[role='combobox']")["aria-label"]
    assert_equal "City", doc.at_css("[role='listbox']")["aria-label"]
  end

  def test_labelledby_names_the_control_and_listbox
    doc = render_dropdown(labelledby: "city_label")

    assert_equal "city_label", doc.at_css("[role='combobox']")["aria-labelledby"]
    assert_equal "city_label", doc.at_css("[role='listbox']")["aria-labelledby"]
  end

  def test_select_only_shows_a_trailing_icon_by_default
    assert_css render_dropdown, "[role='combobox'] ~ [aria-hidden='true']"
    assert_no_css render_typeahead, "[role='combobox'] ~ *"
  end

  def test_blank_value_selects_no_option
    doc = render_dropdown(options: [["Choose", ""], %w[Seoul se]], value: nil)

    assert_no_css doc, "[aria-selected='true']"
    assert_equal "", doc.at_css("button[role='combobox']").text
    assert_no_css render_dropdown(options: [["Choose", ""], %w[Seoul se]], value: ""), "[aria-selected='true']"
  end

  def test_value_policy_and_close_on_select_values
    doc = render_typeahead(value_policy: :freeform, close_on_select: false)

    assert_css doc, "[data-combobox-value-policy-value='freeform'][data-combobox-close-on-select-value='false']"
    assert_no_css render_dropdown, "[data-combobox-value-policy-value], [data-combobox-close-on-select-value]"
  end

  def test_invalid_value_policy_raises
    assert_raises(ArgumentError) { render_typeahead(value_policy: :anything) }
  end

  def test_editable_filtering_values
    doc = render_typeahead(match: :contains, min_length: 2)

    assert_css doc, "[data-combobox-match-value='contains'][data-combobox-min-length-value='2']"
    assert_css doc, "[data-combobox-empty-text-value='No results']"
  end

  def test_editable_options_raise_on_select_only
    error = assert_raises(ArgumentError) { render_dropdown(match: :prefix, min_length: 2) }

    assert_includes error.message, "match, min_length"
    assert_raises(ArgumentError) { render_typeahead(match: :regex) }
  end

  def test_editable_control_autocompletes_a_list
    assert_equal "list", render_typeahead.at_css("[role='combobox']")["aria-autocomplete"]
    assert_nil render_dropdown.at_css("[role='combobox']")["aria-autocomplete"]
  end

  def test_source_wires_the_turbo_adapter_and_skips_local_matching
    container = render_typeahead(source: "/cities", param: :term).at_css("[data-controller]")

    assert_equal "combobox combobox-turbo", container["data-controller"]
    assert_includes container["data-action"], "combobox:query->combobox-turbo#onQuery"
    assert_includes container["data-action"], "combobox:closed->combobox-turbo#onClosed"
    assert_equal "/cities", container["data-combobox-turbo-src-value"]
    assert_equal "term", container["data-combobox-turbo-param-value"]
    assert_equal "none", container["data-combobox-match-value"]
  end

  def test_source_status_text
    container = render_typeahead(source: "/cities").at_css("[data-controller]")

    assert_equal "Loading…", container["data-combobox-turbo-loading-text-value"]
    assert_equal "Results could not be loaded", container["data-combobox-turbo-error-text-value"]
  end

  def test_source_renders_the_listbox_inside_a_results_frame
    doc   = render_typeahead(source: "/cities")
    frame = doc.at_css("#city_popover > turbo-frame#city_popover_results")

    assert_equal "frame", frame["data-combobox-turbo-target"]
    assert_includes frame["data-action"], "turbo:before-fetch-response->combobox-turbo#onResponse"
    assert_includes frame["data-action"], "turbo:frame-missing->combobox-turbo#onError"
    assert_includes frame["data-action"], "turbo:fetch-request-error->combobox-turbo#onError"
    assert_css frame, "> ul#city_popover_listbox[role='listbox']"
    assert_css doc, "#city_popover > [role='status'][data-combobox-target='status'][data-combobox-turbo-target='status']"
  end

  def test_local_typeahead_has_no_results_frame
    doc = render_typeahead

    assert_no_css doc, "turbo-frame, [data-combobox-turbo-target]"
    assert_equal "combobox", doc.at_css("[data-controller]")["data-controller"]
  end

  def test_source_needs_a_stable_id_and_no_match
    error = assert_raises(ArgumentError) do
      StimulusPlumbers::Components::Combobox::Typeahead.new(self).render(source: "/cities")
    end

    assert_includes error.message, "id:"
    assert_raises(ArgumentError) { render_typeahead(source: "/cities", id: "") }
    assert_raises(ArgumentError) { render_typeahead(source: "/cities", match: :prefix) }
    assert_raises(ArgumentError) { render_dropdown(source: "/cities") }
    assert_includes assert_raises(ArgumentError) { render_typeahead(param: :term) }.message, "source:"
  end

  def test_editable_panel_has_a_status_after_the_listbox
    status = render_typeahead.at_css("#city_popover > [role='status']")

    assert_equal "status", status["data-combobox-target"]
    assert_equal "city_popover_listbox", status.previous_element["id"]
    assert_no_css render_dropdown, "[role='status']"
  end

  def test_editable_status_takes_the_status_theme
    original = StimulusPlumbers.config.theme.current
    StimulusPlumbers.config.theme.use(status_theme)

    assert_css render_typeahead, "[role='status'].sp-status"
  ensure
    StimulusPlumbers.config.theme.use(original)
  end

  def status_theme
    Class.new(StimulusPlumbers::Themes::Base) do
      def combobox_status_classes(**)
        { classes: "sp-status" }
      end
    end.new
  end

  def test_trigger_options_merge_onto_the_trigger
    control = render_dropdown(trigger: { aria: { required: "true" }, data: { testid: "c" } }).at_css("[role='combobox']")

    assert_equal "true", control["aria-required"]
    assert_equal "c", control["data-testid"]
    assert_equal "trigger", control["data-combobox-target"]
  end

  def test_html_options_go_to_the_container
    assert_css render_dropdown(class: "my-combobox", data: { testid: "cb" }),
               "div.my-combobox[data-testid='cb'][data-controller='combobox']"
  end
end
