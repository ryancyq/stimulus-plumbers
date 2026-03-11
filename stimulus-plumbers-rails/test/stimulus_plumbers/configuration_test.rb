# frozen_string_literal: true

require "test_helper"

class ConfigurationTest < Minitest::Test
  def setup
    @config = StimulusPlumbers::Configuration.new
  end

  # #theme
  def test_theme_defaults_to_a_tailwind_instance
    assert_instance_of StimulusPlumbers::Themes::TailwindTheme, @config.theme
  end

  def test_theme_is_memoized
    assert_same @config.theme, @config.theme
  end

  # #theme=
  def test_theme_setter_accepts_tailwind_symbol
    @config.theme = :tailwind

    assert_instance_of StimulusPlumbers::Themes::TailwindTheme, @config.theme
  end

  def test_theme_setter_accepts_a_themes_base_instance_directly
    custom = StimulusPlumbers::Themes::Base.new
    @config.theme = custom

    assert_same custom, @config.theme
  end

  def test_theme_setter_raises_argument_error_for_an_unknown_symbol
    err = assert_raises(ArgumentError) { @config.theme = :unknown }
    assert_match %r{Unknown theme}, err.message
    assert_match %r{StimulusPlumbers::Themes::UnknownTheme}, err.message
  end

  # #log_formatter
  def test_log_formatter_defaults_to_the_built_in_prefix_formatter
    assert_equal "[StimulusPlumbers] hello", @config.log_formatter.call("hello")
  end

  def test_log_formatter_is_memoized
    assert_same @config.log_formatter, @config.log_formatter
  end

  # #log_formatter=
  def test_log_formatter_setter_accepts_any_callable
    @config.log_formatter = ->(msg) { "PREFIX: #{msg}" }

    assert_equal "PREFIX: test", @config.log_formatter.call("test")
  end

  def test_log_formatter_setter_accepts_a_proc
    @config.log_formatter = proc(&:upcase)

    assert_equal "TEST", @config.log_formatter.call("test")
  end

  def test_log_formatter_setter_raises_argument_error_when_given_a_non_callable
    err = assert_raises(ArgumentError) { @config.log_formatter = "a string" }
    assert_match %r{respond to #call}, err.message
  end

  def test_log_formatter_setter_raises_argument_error_when_given_nil
    err = assert_raises(ArgumentError) { @config.log_formatter = nil }
    assert_match %r{respond to #call}, err.message
  end
end
