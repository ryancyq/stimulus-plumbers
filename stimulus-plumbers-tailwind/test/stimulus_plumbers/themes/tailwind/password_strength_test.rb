# frozen_string_literal: true

require "test_helper"

class TailwindThemePasswordStrengthTest < Minitest::Test
  include ThemeAssertions

  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def test_rule_is_muted_by_default
    assert_includes classes_for(:password_strength_rule), "text-(--sp-color-muted-fg)"
  end

  def test_satisfied_rule_turns_success_and_strikes_through
    classes = classes_for(:password_strength_rule)

    assert_includes classes, "data-[satisfied=true]:text-(--sp-color-success)"
    assert_includes classes, "data-[satisfied=true]:line-through"
  end

  def test_rules_heading_is_muted
    assert_includes classes_for(:password_strength_rules_heading), "text-(--sp-color-muted-fg)"
  end

  def test_level_is_semibold
    assert_includes classes_for(:password_strength_level), "font-semibold"
  end
end
