# frozen_string_literal: true

require "test_helper"

class BaseThemeComboboxTest < StubThemeTestCase
  def test_coerces_invalid_selected_value_to_false_and_warns
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value "yes"}])
    Rails.stub(:logger, mock_logger) do
      @theme.resolve(:combobox_option, selected: "yes")
    end
    mock_logger.verify
  end

  def test_coerces_invalid_disabled_value_to_false_and_warns
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value "yes"}])
    Rails.stub(:logger, mock_logger) do
      @theme.resolve(:combobox_option, disabled: "yes")
    end
    mock_logger.verify
  end
end
