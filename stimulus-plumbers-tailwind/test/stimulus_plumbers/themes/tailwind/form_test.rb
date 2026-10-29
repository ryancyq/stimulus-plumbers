# frozen_string_literal: true

require "test_helper"

class TailwindThemeFormTest < Minitest::Test
  include ThemeAssertions

  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  # :form_group

  def test_form_group_stacked_layout_puts_the_label_above_the_control
    result = classes_for(:form_group, layout: :stacked)

    assert_includes result, "flex-col"
    refute_includes result, "flex-row"
  end

  def test_form_group_inline_layout_puts_the_label_beside_the_control
    result = classes_for(:form_group, layout: :inline)

    assert_includes result, "flex-row"
    assert_includes result, "items-center"
    refute_includes result, "flex-col"
  end

  # :form_submit_label

  def test_form_submit_label_is_visually_hidden_when_requested
    assert_includes classes_for(:form_submit_label, hidden: true), "sr-only"
  end
end
