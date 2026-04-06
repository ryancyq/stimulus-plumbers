# frozen_string_literal: true

require "test_helper"

class DatePickerHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::PlumberHelper
  include StimulusPlumbers::Helpers::DatePickerHelper

  class TestRecord
    def self.model_name
      ActiveModel::Name.new(self, nil, "TestRecord")
    end

    def to_key
      nil
    end
  end

  def test_renders_datepicker
    assert_includes sp_date_picker_month, 'data-controller="datepicker'
  end

  def test_passes_html_options
    assert_includes sp_date_picker_month(id: "picker"), 'id="picker"'
  end

  def test_generates_unique_calendar_id_without_record
    first  = sp_date_picker_month
    second = sp_date_picker_month

    id1 = first[%r{data-datepicker-calendar-month-outlet="#([^"]+)"}, 1]
    id2 = second[%r{data-datepicker-calendar-month-outlet="#([^"]+)"}, 1]

    assert_predicate id1, :present?
    assert_predicate id2, :present?
    assert_not_equal id1, id2
  end

  def test_uses_record_and_attribute_as_calendar_id
    record = TestRecord.new
    html   = sp_date_picker_month(record, :start)

    assert_includes html, "start_date_new_test_record"
  end
end
