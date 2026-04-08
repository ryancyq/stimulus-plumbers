# frozen_string_literal: true

require "test_helper"

class DatePickerHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::PlumberHelper
  include StimulusPlumbers::Helpers::DatePickerHelper

  def test_forwards_html_options
    assert_includes sp_date_picker_month(id: "picker"), 'id="picker"'
  end

  def test_dialog_id_without_record_is_unique_and_prefixed_with_date
    id1 = sp_date_picker_month[%r{aria-controls="([^"]+)"}, 1]
    id2 = sp_date_picker_month[%r{aria-controls="([^"]+)"}, 1]

    assert_match(%r{\Adate_}, id1)
    assert_not_equal id1, id2
  end

  def test_dialog_id_with_record_and_no_attribute
    assert_includes sp_date_picker_month(TestRecord.new), 'aria-controls="date_test_record_dialog"'
  end

  def test_dialog_id_with_record_and_attribute
    assert_includes sp_date_picker_month(TestRecord.new, :start), 'aria-controls="start_date_test_record_dialog"'
  end
end
