# frozen_string_literal: true

require "test_helper"

class TailwindIconsCustomTest < Minitest::Test
  Custom = StimulusPlumbers::Themes::Tailwind::Icons::Custom

  # ── include? ──────────────────────────────────────────────────────────────

  def test_include_returns_true_for_known_icon
    assert_includes Custom, "spinner"
  end

  def test_include_returns_false_for_unknown_icon
    refute_includes Custom, "does-not-exist"
  end

  # ── fetch ─────────────────────────────────────────────────────────────────

  def test_fetch_returns_nil_for_unknown_icon
    assert_nil Custom.fetch("does-not-exist")
  end

  def test_fetch_spinner_returns_a_hash
    assert_instance_of Hash, Custom.fetch("spinner")
  end

  def test_fetch_spinner_has_elements
    assert_predicate Custom.fetch("spinner")[:elements], :any?
  end

  def test_fetch_spinner_reads_svg_root_attrs
    result = Custom.fetch("spinner")

    assert_equal "0 0 100 101", result[:view_box]
    assert_equal "none",        result[:fill]
    assert_equal "none",        result[:stroke]
  end

  def test_fetch_spinner_elements_have_tag_and_d
    el = Custom.fetch("spinner")[:elements].first

    assert_equal :path, el[:tag]
    assert_predicate el[:d], :present?
  end

  def test_fetch_spinner_elements_have_fill_and_opacity
    els = Custom.fetch("spinner")[:elements]

    assert_equal "currentColor", els.first[:fill]
    assert_equal "0.25",         els.first[:opacity]
    assert_equal "currentColor", els.last[:fill]
  end
end
