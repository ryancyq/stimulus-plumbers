# frozen_string_literal: true

require "test_helper"

class BaseThemeFormTest < Minitest::Test
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

  def test_coerces_invalid_form_group_layout_to_default_and_warns
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value :grid}])
    Rails.stub(:logger, mock_logger) do
      @theme.resolve(:form_group, layout: :grid)
    end
    mock_logger.verify
  end

  def test_coerces_invalid_form_group_error_to_default_and_warns
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value "yes"}])
    Rails.stub(:logger, mock_logger) do
      @theme.resolve(:form_group, error: "yes")
    end
    mock_logger.verify
  end

  def test_coerces_invalid_form_input_error_to_default_and_warns
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value "yes"}])
    Rails.stub(:logger, mock_logger) do
      @theme.resolve(:form_input, error: "yes")
    end
    mock_logger.verify
  end

  def test_coerces_invalid_form_submit_variant_to_default_and_warns
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value :icon}])
    Rails.stub(:logger, mock_logger) do
      @theme.resolve(:form_submit, variant: :icon)
    end
    mock_logger.verify
  end

  def test_coerces_invalid_form_label_hidden_to_default_and_warns
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value "yes"}])
    Rails.stub(:logger, mock_logger) do
      @theme.resolve(:form_label, hidden: "yes")
    end
    mock_logger.verify
  end

  def test_coerces_invalid_form_label_required_to_default_and_warns
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value "yes"}])
    Rails.stub(:logger, mock_logger) do
      @theme.resolve(:form_label, required: "yes")
    end
    mock_logger.verify
  end

  def test_coerces_invalid_form_input_group_error_to_default_and_warns
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value "yes"}])
    Rails.stub(:logger, mock_logger) do
      @theme.resolve(:form_input_group, error: "yes")
    end
    mock_logger.verify
  end
end
