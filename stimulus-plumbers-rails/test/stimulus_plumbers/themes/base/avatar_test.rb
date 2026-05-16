# frozen_string_literal: true

require "test_helper"

class BaseThemeAvatarTest < Minitest::Test
  def setup
    @theme = build_stub_theme
  end

  def build_stub_theme(with_color_range: false)
    Class.new(StimulusPlumbers::Themes::Base) do
      private

      StimulusPlumbers::Themes::Base::SCHEMA.each_key do |component|
        define_method(:"#{component}_classes") { |**| {} }
      end

      define_method(:avatar_color_range) { %w[red blue] } if with_color_range
    end.new
  end

  def test_coerces_invalid_size_to_default_and_warns
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value :xl}])
    Rails.stub(:logger, mock_logger) do
      @theme.resolve(:avatar, size: :xl)
    end
    mock_logger.verify
  end

  def test_accepts_any_color_when_range_method_not_defined
    assert_equal({}, @theme.resolve(:avatar, color: "anything"))
  end

  def test_coerces_invalid_color_to_default_and_warns_when_range_method_defined
    theme = build_stub_theme(with_color_range: true)
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value "green"}])
    Rails.stub(:logger, mock_logger) do
      theme.resolve(:avatar, color: "green")
    end
    mock_logger.verify
  end

  def test_accepts_valid_color_when_range_method_defined
    theme = build_stub_theme(with_color_range: true)

    assert_equal({}, theme.resolve(:avatar, color: "red"))
  end
end
