# frozen_string_literal: true

require "test_helper"

class TailwindIconsRegistryTest < Minitest::Test
  Registry = StimulusPlumbers::Themes::Icons::Registry

  SOURCES = [
    StimulusPlumbers::Themes::Tailwind::Icons::Custom,
    StimulusPlumbers::Themes::Tailwind::Icons::Heroicon
  ].freeze

  def registry
    @registry ||= Registry.new(sources: SOURCES, aliases: { "close" => "x-mark" })
  end

  # ── aliases ───────────────────────────────────────────────────────────────

  def test_aliases_returns_injected_aliases
    assert_equal({ "close" => "x-mark" }, registry.aliases)
  end

  # ── [] ────────────────────────────────────────────────────────────────────

  def test_fetch_heroicon_by_name
    assert registry["arrow-left"]
  end

  def test_fetch_custom_icon_by_name
    assert registry["spinner"]
  end

  def test_fetch_alias_resolves_to_same_data_as_target
    assert_equal registry["x-mark"], registry["close"]
  end

  def test_fetch_returns_nil_for_unknown
    assert_nil registry["does-not-exist"]
  end

  def test_fetch_memoizes_result
    assert_same registry["arrow-left"], registry["arrow-left"]
  end

  # ── key? ──────────────────────────────────────────────────────────────────

  def test_key_true_for_known_heroicon
    assert registry.key?("arrow-left")
  end

  def test_key_true_for_known_custom_icon
    assert registry.key?("spinner")
  end

  def test_key_true_for_alias
    assert registry.key?("close")
  end

  def test_key_false_for_unknown
    refute registry.key?("does-not-exist")
  end

  def test_include_is_alias_for_key
    assert_includes registry, "arrow-left"
    refute_includes registry, "does-not-exist"
  end
end
