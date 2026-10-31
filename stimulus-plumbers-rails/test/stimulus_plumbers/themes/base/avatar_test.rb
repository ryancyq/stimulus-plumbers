# frozen_string_literal: true

require "test_helper"

class BaseThemeAvatarTest < StubThemeTestCase
  def build_stub_theme(with_variant_range: false)
    Class.new(StimulusPlumbers::Themes::Base) do
      private

      StimulusPlumbers::Themes::Base::SCHEMA.each_key do |component|
        define_method(:"#{component}_classes") { |**| {} }
      end

      define_method(:avatar_variant_range) { %i[red blue] } if with_variant_range
    end.new
  end

  def test_coerces_invalid_size_to_default_and_warns
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value :huge}])
    Rails.stub(:logger, mock_logger) do
      @theme.resolve(:avatar, size: :huge)
    end
    mock_logger.verify
  end

  def test_warns_on_any_variant_without_a_variant_range
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value :red}])
    Rails.stub(:logger, mock_logger) do
      @theme.resolve(:avatar, variant: :red)
    end
    mock_logger.verify
  end

  def test_coerces_a_variant_outside_the_range_to_default_and_warns
    theme = build_stub_theme(with_variant_range: true)
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value :green}])
    Rails.stub(:logger, mock_logger) do
      theme.resolve(:avatar, variant: :green)
    end
    mock_logger.verify
  end

  def test_accepts_a_variant_in_the_range
    theme = build_stub_theme(with_variant_range: true)
    mock_logger = Minitest::Mock.new
    Rails.stub(:logger, mock_logger) do
      theme.resolve(:avatar, variant: :red)
    end
    mock_logger.verify
  end
end
