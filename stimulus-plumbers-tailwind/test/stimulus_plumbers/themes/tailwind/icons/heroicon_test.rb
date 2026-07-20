# frozen_string_literal: true

require "test_helper"

class TailwindIconsHeroiconTest < Minitest::Test
  Heroicon = StimulusPlumbers::Themes::Tailwind::Icons::Heroicon

  # ── svg_dir ───────────────────────────────────────────────────────────────

  def test_svg_dir_exists
    assert File.directory?(Heroicon.send(:svg_dir))
  end

  # ── include? ──────────────────────────────────────────────────────────────

  def test_include_returns_true_for_known_outline_icon
    assert_includes Heroicon, "arrow-left"
  end

  def test_include_returns_true_for_known_solid_icon
    assert_includes Heroicon, "arrow-left/solid"
  end

  def test_include_returns_false_for_unknown_icon
    refute_includes Heroicon, "does-not-exist"
  end

  # ── fetch ─────────────────────────────────────────────────────────────────

  def test_fetch_returns_nil_for_unknown_icon
    assert_nil Heroicon.fetch("does-not-exist")
  end

  def test_fetch_outline_returns_elements
    result = Heroicon.fetch("arrow-left")

    assert_predicate result[:elements], :any?
  end

  def test_fetch_outline_reads_svg_root_attrs
    result = Heroicon.fetch("arrow-left")

    assert_equal "none",         result[:fill]
    assert_equal "currentColor", result[:stroke]
    assert_equal "0 0 24 24",    result[:view_box]
    assert_equal "1.5",          result[:stroke_width]
  end

  def test_resolved_icon_is_hidden_from_assistive_technology
    resolved = StimulusPlumbers::Themes::Schema::Icon.resolve(Heroicon.fetch("eye"))

    assert_equal "true", resolved["aria-hidden"]
  end

  def test_fetch_solid_returns_elements
    result = Heroicon.fetch("arrow-left/solid")

    assert_predicate result[:elements], :any?
  end

  def test_fetch_solid_applies_fill_and_stroke_defaults
    result = Heroicon.fetch("arrow-left/solid")

    assert_equal "currentColor", result[:fill]
    assert_equal "none",         result[:stroke]
  end

  def test_fetch_elements_have_tag_and_d
    el = Heroicon.fetch("arrow-left")[:elements].first

    assert_equal :path, el[:tag]
    assert_predicate el[:d], :present?
  end

  # ── private methods ──────────────────────────────────────────────────────

  def test_parse_elements_is_private
    assert_raises(NoMethodError) { Heroicon.parse_elements(nil) }
  end

  def test_parse_element_is_private
    assert_raises(NoMethodError) { Heroicon.parse_element(nil) }
  end
end
