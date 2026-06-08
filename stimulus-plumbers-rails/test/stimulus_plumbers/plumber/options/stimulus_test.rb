# frozen_string_literal: true

require "test_helper"

class PlumberOptionsStimulusTest < Minitest::Test
  def instance
    Class.new { include StimulusPlumbers::Plumber::Options::Stimulus }.new
  end

  def test_space_joins_controller_and_action
    result = instance.merge_stimulus_data(
      { controller: "base", action: "click->base#act" },
      { controller: "extra", action: "keydown->extra#act" }
    )

    assert_equal "base extra",                         result[:controller]
    assert_equal "click->base#act keydown->extra#act", result[:action]
  end

  def test_preserves_non_stimulus_keys
    result = instance.merge_stimulus_data(
      { controller: "ctrl", target: "el" },
      { foo: "bar" }
    )

    assert_equal "ctrl", result[:controller]
    assert_equal "el",   result[:target]
    assert_equal "bar",  result[:foo]
  end

  def test_overwrites_duplicate_non_stimulus_keys
    result = instance.merge_stimulus_data({ target: "old" }, { target: "new" })

    assert_equal "new", result[:target]
  end

  def test_custom_spacejoin_overrides_default_keys
    result = instance.merge_stimulus_data(
      { controller: "base", custom: "a" },
      { controller: "extra", custom: "b" },
      spacejoin: %i[custom]
    )

    assert_equal "extra", result[:controller]
    assert_equal "a b",   result[:custom]
  end
end
