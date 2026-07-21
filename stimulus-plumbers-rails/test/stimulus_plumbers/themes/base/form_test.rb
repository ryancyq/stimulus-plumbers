# frozen_string_literal: true

require "test_helper"

class BaseThemeFormTest < StubThemeTestCase
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
      @theme.resolve(:form_field_input, error: "yes")
    end
    mock_logger.verify
  end

  def test_coerces_invalid_form_label_hidden_to_default_and_warns
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value "yes"}])
    Rails.stub(:logger, mock_logger) do
      @theme.resolve(:form_field_label, hidden: "yes")
    end
    mock_logger.verify
  end

  def test_coerces_invalid_form_label_required_to_default_and_warns
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value "yes"}])
    Rails.stub(:logger, mock_logger) do
      @theme.resolve(:form_field_label, required: "yes")
    end
    mock_logger.verify
  end

  def test_coerces_invalid_input_group_error_to_default_and_warns
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value "yes"}])
    Rails.stub(:logger, mock_logger) do
      @theme.resolve(:input_group, error: "yes")
    end
    mock_logger.verify
  end

  def test_resolves_valid_form_input_reveal_error_without_warning
    mock_logger = Minitest::Mock.new
    Rails.stub(:logger, mock_logger) do
      @theme.resolve(:form_field_input_reveal, error: true)
    end
    mock_logger.verify
  end

  def test_coerces_invalid_form_input_reveal_error_to_default_and_warns
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value "yes"}])
    Rails.stub(:logger, mock_logger) do
      @theme.resolve(:form_field_input_reveal, error: "yes")
    end
    mock_logger.verify
  end

  def test_password_strength_keys_resolve_to_no_ops
    %i[
      password_strength_wrapper password_strength_rules
      password_strength_rule_icon password_strength_level
    ].each do |key|
      assert_empty @theme.resolve(key)
    end
  end

  def test_password_strength_rule_resolves_empty
    assert_empty @theme.resolve(:password_strength_rule)
  end
end
