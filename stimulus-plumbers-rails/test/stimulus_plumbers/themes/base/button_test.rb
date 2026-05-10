# frozen_string_literal: true

require "test_helper"

class BaseThemeButtonTest < Minitest::Test
  def setup
    @theme = build_stub_theme
  end

  def build_stub_theme
    Class.new(StimulusPlumbers::Themes::Base) do
      private

      StimulusPlumbers::Themes::Base::SCHEMA.each_key do |component|
        define_method(:"#{component}_classes") { |**| {} }
      end
    end.new
  end

  def test_coerces_invalid_variant_to_default_and_warns
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value :invalid}])
    Rails.stub(:logger, mock_logger) do
      @theme.resolve(:button, variant: :invalid)
    end
    mock_logger.verify
  end

  def test_coerces_invalid_size_to_default_and_warns
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value :xl}])
    Rails.stub(:logger, mock_logger) do
      @theme.resolve(:button, size: :xl)
    end
    mock_logger.verify
  end

  def test_coerces_invalid_alignment_to_default_and_warns
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value :diagonal}])
    Rails.stub(:logger, mock_logger) do
      @theme.resolve(:button_group, alignment: :diagonal)
    end
    mock_logger.verify
  end

  def test_coerces_invalid_direction_to_default_and_warns
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value :diagonal}])
    Rails.stub(:logger, mock_logger) do
      @theme.resolve(:button_group, direction: :diagonal)
    end
    mock_logger.verify
  end
end
