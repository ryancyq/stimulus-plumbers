# frozen_string_literal: true

require "test_helper"
require_relative "../../form_builder_model"

class ProgressTest < ActionView::TestCase
  def setup
    @form = FormBuilderModel.new(completion: 45, profile_strength: 4)
  end

  def build_field(attribute = :completion, **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.field(attribute, as: :progress, **opts)
    end
    parse_html(html)
  end

  def bar(doc)
    doc.at_css("[role='progressbar']")
  end

  def test_label_is_not_a_label_element
    assert_no_css build_field, "label"
  end

  def test_label_renders_as_a_span_with_the_humanized_attribute
    label = build_field.at_css("span#sign_in_form_completion_label")

    assert_equal "Completion", label.text
  end

  def test_progressbar_is_named_by_the_field_label
    assert_equal "sign_in_form_completion_label", bar(build_field)["aria-labelledby"]
  end

  def test_value_comes_from_the_model_attribute
    assert_equal "45", bar(build_field)["aria-valuenow"]
  end

  def test_format_renders_the_readout
    assert_equal "45%", build_field(format: :percent).at_css("[data-progress-target='value']").text
  end

  def test_segments_render_the_segmented_variant
    doc = build_field(:profile_strength, segments: 5, max: 5)

    assert_equal "segmented", bar(doc)["data-progress-variant-value"]
    assert_equal 5, doc.css("[data-progress-target='fill']").size
  end

  def test_hint_is_described_by_the_progressbar
    doc = build_field(hint: "Since last sync")

    assert_equal "sign_in_form_completion_hint", bar(doc)["aria-describedby"]
  end

  def test_required_does_not_reach_the_progressbar
    element = bar(build_field(required: true))

    assert_nil element["required"]
    assert_nil element["aria-required"]
  end

  def test_errors_are_described_but_not_marked_invalid
    doc = build_field(error: "Sync failed")

    assert_nil bar(doc)["aria-invalid"]
    assert_includes doc.text, "Sync failed"
    assert_includes bar(doc)["aria-describedby"].to_s, "sign_in_form_completion_error"
  end

  def test_format_with_segments_raises
    assert_raises(ArgumentError) { build_field(:profile_strength, segments: 5, format: :percent) }
  end

  def test_floating_is_ignored_for_an_aria_labelled_field
    doc = build_field(floating: :floating_outlined)

    assert_css doc, "span#sign_in_form_completion_label"
    assert_no_css doc, "[placeholder]"
  end

  # hide_label is visual only — the caption must stay in the DOM or the bar loses its name.
  def test_hidden_label_still_names_the_progressbar
    doc = build_field(hide_label: true)

    assert_css doc, "span#sign_in_form_completion_label"
    assert_equal "Completion", doc.at_css("span#sign_in_form_completion_label").text
    assert_equal "sign_in_form_completion_label", bar(doc)["aria-labelledby"]
    assert_no_css doc, "label"
  end

  def test_readout_placement_reaches_the_bar_without_leaking_as_an_attribute
    doc = build_field(format: :percent, readout: :outside)

    assert_nil bar(doc)["readout"]
    refute_equal bar(doc), doc.at_css("[data-progress-target='fill']").parent
    assert_equal "45%", doc.at_css("[data-progress-target='value']").text
  end

  def test_required_adds_no_marker_or_control_attributes
    doc = build_field(required: true)

    assert_nil bar(doc)["required"]
    assert_nil bar(doc)["aria-required"]
    assert_nil bar(doc)["aria-invalid"]
    assert_no_css doc, "span#sign_in_form_completion_label span[aria-hidden='true']"
  end
end
