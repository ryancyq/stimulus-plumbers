# frozen_string_literal: true

require "test_helper"

class LoggerTest < Minitest::Test
  def teardown
    StimulusPlumbers.config.log_formatter = StimulusPlumbers::Configuration::DEFAULT_LOG_FORMATTER
  end

  # log levels — delegates each level to Rails.logger with formatted message
  StimulusPlumbers::Logger::LEVELS.each do |level|
    define_method("test_#{level}_formats_message_and_delegates_to_rails_logger") do
      mock_logger = Minitest::Mock.new
      mock_logger.expect(level, nil, ["[StimulusPlumbers] test message"])
      Rails.stub(:logger, mock_logger) do
        StimulusPlumbers::Logger.public_send(level, "test message")
      end
      mock_logger.verify
    end
  end

  def test_applies_the_configured_formatter_before_delegating
    StimulusPlumbers.config.log_formatter = ->(msg) { "CUSTOM: #{msg}" }
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, ["CUSTOM: hello"])
    Rails.stub(:logger, mock_logger) do
      StimulusPlumbers::Logger.warn("hello")
    end
    mock_logger.verify
  end
end
