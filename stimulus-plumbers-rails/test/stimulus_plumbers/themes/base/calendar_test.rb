# frozen_string_literal: true

require "test_helper"

class BaseThemeCalendarTest < StubThemeTestCase
  def test_coerces_invalid_today_value_to_false_and_warns
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value "yes"}])
    Rails.stub(:logger, mock_logger) do
      @theme.resolve(:calendar_day, today: "yes")
    end
    mock_logger.verify
  end

  def test_coerces_invalid_selected_value_to_false_and_warns
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value "yes"}])
    Rails.stub(:logger, mock_logger) do
      @theme.resolve(:calendar_day, selected: "yes")
    end
    mock_logger.verify
  end

  def test_coerces_invalid_outside_value_to_false_and_warns
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value "yes"}])
    Rails.stub(:logger, mock_logger) do
      @theme.resolve(:calendar_day, outside: "yes")
    end
    mock_logger.verify
  end
end
