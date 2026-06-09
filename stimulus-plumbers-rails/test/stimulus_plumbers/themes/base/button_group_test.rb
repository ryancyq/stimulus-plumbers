# frozen_string_literal: true

require "test_helper"

class BaseThemeButtonGroupTest < StubThemeTestCase
  def test_coerces_invalid_layout_to_default_and_warns
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value :diagonal}])
    Rails.stub(:logger, mock_logger) do
      @theme.resolve(:button_group, layout: :diagonal)
    end
    mock_logger.verify
  end
end
