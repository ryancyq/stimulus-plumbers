# frozen_string_literal: true

require "test_helper"

class BaseThemeButtonTest < StubThemeTestCase
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

  def test_button_icon_resolves
    assert_equal({}, @theme.resolve(:button_icon))
  end
end
