# frozen_string_literal: true

require "test_helper"

class ChecklistHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::ChecklistHelper

  def test_sp_checklist_renders_a_group
    doc = parse_html(sp_checklist { |c| c.item("Buy milk", checked: true) })

    assert_css doc, "div[role='group']"
  end
end
