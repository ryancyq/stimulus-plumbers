# frozen_string_literal: true

require "test_helper"

class BaseThemeActionListTest < StubThemeTestCase
  def test_coerces_invalid_active_value_to_false_and_warns
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value "yes"}])
    Rails.stub(:logger, mock_logger) do
      @theme.resolve(:action_list_item, active: "yes")
    end
    mock_logger.verify
  end
end
