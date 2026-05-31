# frozen_string_literal: true

require "test_helper"

class PlumberStimulusOptionsTest < Minitest::Test
  def instance
    obj = Object.new
    obj.extend(StimulusPlumbers::Plumber::StimulusOptions)
    obj.extend(StimulusPlumbers::Plumber::ThemeOptions)
    obj
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
end
