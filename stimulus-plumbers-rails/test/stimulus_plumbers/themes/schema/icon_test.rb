# frozen_string_literal: true

require "test_helper"

class SchemaIconTest < Minitest::Test
  Icon = StimulusPlumbers::Themes::Schema::Icon

  # ── DEFAULTS ─────────────────────────────────────────────────────────────

  def test_defaults_includes_all_svg_attribute_keys
    assert_includes Icon::DEFAULTS, :fill
    assert_includes Icon::DEFAULTS, :view_box
    assert_includes Icon::DEFAULTS, :width
    assert_includes Icon::DEFAULTS, :height
    assert_includes Icon::DEFAULTS, :stroke
    assert_includes Icon::DEFAULTS, :stroke_width
    assert_includes Icon::DEFAULTS, :stroke_linecap
    assert_includes Icon::DEFAULTS, :stroke_linejoin
  end

  def test_defaults_does_not_include_d
    refute_includes Icon::DEFAULTS, :d
  end

  # ── ATTRS ─────────────────────────────────────────────────────────────────

  def test_attrs_includes_d_and_all_default_keys
    assert_includes Icon::ATTRS, :d
    Icon::DEFAULTS.each_key { |k| assert_includes Icon::ATTRS, k }
  end

  # ── resolve ───────────────────────────────────────────────────────────────

  def test_resolve_returns_nil_for_nil_input
    assert_nil Icon.resolve(nil)
  end

  def test_resolve_returns_nil_when_d_is_missing
    assert_nil Icon.resolve({})
  end

  def test_resolve_returns_nil_when_d_is_blank
    assert_nil Icon.resolve({ d: "" })
  end

  def test_resolve_returns_hash_with_valid_icon_data
    result = Icon.resolve({ d: "M1 2 3 4" })

    assert_instance_of Hash, result
  end

  def test_resolve_includes_d_value
    result = Icon.resolve({ d: "M1 2 3 4" })

    assert_equal "M1 2 3 4", result[:d]
  end

  def test_resolve_applies_fill_and_view_box_defaults
    result = Icon.resolve({ d: "M1 2 3 4" })

    assert_equal "none", result[:fill]
    assert_equal "0 0 24 24", result[:view_box]
  end

  def test_resolve_applies_dimension_defaults
    result = Icon.resolve({ d: "M1 2 3 4" })

    assert_equal "24", result[:width]
    assert_equal "24", result[:height]
  end

  def test_resolve_applies_stroke_defaults
    result = Icon.resolve({ d: "M1 2 3 4" })

    assert_equal "currentColor", result[:stroke]
    assert_equal "1.5", result[:stroke_width]
    assert_equal "round", result[:stroke_linecap]
    assert_equal "round", result[:stroke_linejoin]
  end

  def test_resolve_overrides_default_with_icon_data
    result = Icon.resolve({ d: "M1 2", stroke_width: 2, fill: "red" })

    assert_equal "2",   result[:stroke_width]
    assert_equal "red", result[:fill]
  end

  def test_resolve_coerces_all_values_to_strings
    result = Icon.resolve({ d: "M1 2", stroke_width: 2, stroke_linecap: :square })

    assert_equal "2",      result[:stroke_width]
    assert_equal "square", result[:stroke_linecap]
    result.each_value { |v| assert_instance_of String, v }
  end

  def test_resolve_strips_unknown_keys
    result = Icon.resolve({ d: "M1 2", unknown_key: "ignored", foo: "bar" })

    refute_includes result, :unknown_key
    refute_includes result, :foo
  end

  def test_resolve_warns_when_d_is_missing
    logger = StimulusPlumbers::Logger
    warned = false
    logger.stub(:warn, ->(_msg) { warned = true }) { Icon.resolve({}) }

    assert warned
  end
end
