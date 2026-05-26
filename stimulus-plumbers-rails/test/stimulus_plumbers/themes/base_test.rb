# frozen_string_literal: true

require "test_helper"

class BaseThemeTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::Base.new
  end

  def test_resolve_returns_empty_hash_for_an_unknown_component
    assert_equal({}, @theme.resolve(:nonexistent))
  end

  def test_avatar_colors_returns_empty_hash
    assert_equal({}, @theme.avatar_colors)
  end

  def test_avatar_color_range_returns_empty_array
    assert_equal([], @theme.avatar_color_range)
  end

  def test_valid_nil_validator_accepts_any_value
    assert @theme.send(:valid?, nil, :anything)
  end

  def test_valid_array_accepts_included_value
    assert @theme.send(:valid?, %i[xs sm md], :sm)
  end

  def test_valid_array_rejects_excluded_value
    refute @theme.send(:valid?, %i[xs sm md], :xl)
  end

  def test_valid_range_accepts_included_value
    assert @theme.send(:valid?, 1..10, 5)
  end

  def test_valid_range_rejects_excluded_value
    refute @theme.send(:valid?, 1..10, 11)
  end

  def test_valid_symbol_0arg_accepts_value_in_collection
    theme = Class.new(StimulusPlumbers::Themes::Base) { def color_range = %w[red blue] }.new

    assert theme.send(:valid?, :color_range, "red")
  end

  def test_valid_symbol_0arg_rejects_value_not_in_collection
    theme = Class.new(StimulusPlumbers::Themes::Base) { def color_range = %w[red blue] }.new

    refute theme.send(:valid?, :color_range, "green")
  end

  def test_valid_symbol_1arg_accepts_when_predicate_returns_true
    theme = Class.new(StimulusPlumbers::Themes::Base) { def icon_valid?(name) = name.start_with?("hero-") }.new

    assert theme.send(:valid?, :icon_valid?, "hero-check")
  end

  def test_valid_symbol_1arg_rejects_when_predicate_returns_false
    theme = Class.new(StimulusPlumbers::Themes::Base) { def icon_valid?(name) = name.start_with?("hero-") }.new

    refute theme.send(:valid?, :icon_valid?, "custom-check")
  end

  def test_valid_proc_0arg_accepts_value_in_collection
    assert @theme.send(:valid?, -> { %w[red blue] }, "red")
  end

  def test_valid_proc_0arg_rejects_value_not_in_collection
    refute @theme.send(:valid?, -> { %w[red blue] }, "green")
  end

  def test_valid_proc_1arg_accepts_when_predicate_returns_true
    assert @theme.send(:valid?, ->(name) { name.start_with?("hero-") }, "hero-check")
  end

  def test_valid_proc_1arg_rejects_when_predicate_returns_false
    refute @theme.send(:valid?, ->(name) { name.start_with?("hero-") }, "custom-check")
  end

  def test_valid_proc_accepts_value_when_instance_method_collection_includes_it
    theme = Class.new(StimulusPlumbers::Themes::Base) { def allowed = %w[red blue] }.new

    assert theme.send(:valid?, ->(v) { allowed.include?(v) }, "red")
  end

  def test_valid_proc_rejects_value_when_instance_method_collection_excludes_it
    theme = Class.new(StimulusPlumbers::Themes::Base) { def allowed = %w[red blue] }.new

    refute theme.send(:valid?, ->(v) { allowed.include?(v) }, "green")
  end

  def test_resolve_returns_empty_hash_and_warns_for_all_known_components
    mock_logger = Minitest::Mock.new
    StimulusPlumbers::Themes::Base::SCHEMA.each_key do |_component|
      mock_logger.expect(:warn, nil, [String])
    end
    Rails.stub(:logger, mock_logger) do
      StimulusPlumbers::Themes::Base::SCHEMA.each_key do |component|
        assert_equal({}, @theme.resolve(component))
      end
    end
    mock_logger.verify
  end
end
