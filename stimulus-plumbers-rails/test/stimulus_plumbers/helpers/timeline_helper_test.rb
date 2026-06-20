# frozen_string_literal: true

require "test_helper"

class TimelineHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::TimelineHelper
  include StimulusPlumbers::Helpers::IconHelper
  include StimulusPlumbers::Helpers::LinkHelper

  def test_renders_ol_element
    doc = parse_html(sp_timeline { "" })

    assert_css doc, "ol"
  end

  def test_renders_li_per_event
    doc = parse_html(sp_timeline do |t|
      concat t.event(datetime: "2024-01-15") { |_e| }
      concat t.event(datetime: "2024-03-01") { |_e| }
    end)

    assert_equal 2, doc.css("li").size
  end

  def test_renders_indicator_dot_when_indicator_called
    doc = parse_html(sp_timeline do |t|
      t.event do |e|
        e.indicator
      end
    end)

    assert_css doc, "li div[aria-hidden='true']"
  end

  def test_renders_icon_indicator_when_icon_given
    doc = parse_html(sp_timeline do |t|
      t.event do |e|
        e.indicator(icon: "check")
      end
    end)

    assert_css doc, "li div[aria-hidden='true']"
  end

  def test_renders_time_with_datetime_attribute
    doc = parse_html(sp_timeline do |t|
      t.event(datetime: "2024-01-15") do |e|
        e.time { "January 2024" }
      end
    end)

    assert_css doc, "time[datetime='2024-01-15']"
    assert_includes doc.css("time").text, "January 2024"
  end

  def test_renders_static_h3_with_title
    doc = parse_html(sp_timeline do |t|
      t.event do |e|
        e.title { "Event title" }
      end
    end)

    assert_css doc, "h3"
    assert_includes doc.css("h3").text, "Event title"
  end

  def test_renders_h3_with_button_for_trigger
    doc = parse_html(sp_timeline do |t|
      t.event do |e|
        e.trigger { "Event title" }
      end
    end)

    assert_css doc, "h3 button"
    assert_css doc, "button[aria-expanded='false']"
    assert_css doc, "button[aria-controls]"
    assert_includes doc.css("h3 button").text, "Event title"
  end

  def test_detail_id_matches_trigger_aria_controls
    doc = parse_html(sp_timeline do |t|
      t.event do |e|
        e.trigger { "Event title" }
        e.detail { "Expanded content" }
      end
    end)

    controls_id = doc.css("button[aria-controls]").first["aria-controls"]
    assert_not_nil controls_id
    assert_css doc, "div[id='#{controls_id}']"
    assert_css doc, "div[hidden]"
    assert_css doc, "div[data-timeline-target='detail']"
  end

  def test_renders_p_for_description
    doc = parse_html(sp_timeline do |t|
      t.event do |e|
        e.description { "Brief description" }
      end
    end)

    assert_css doc, "p"
    assert_includes doc.css("p").text, "Brief description"
  end

  def test_renders_actions_wrapper_when_block_has_content
    doc = parse_html(sp_timeline do |t|
      t.event do |e|
        e.actions { "Read more" }
      end
    end)

    assert_css doc, "li div"
    assert_includes doc.text, "Read more"
  end

  def test_suppresses_actions_wrapper_when_block_is_empty
    doc = parse_html(sp_timeline do |t|
      t.event do |e|
        e.title { "Title" }
        e.actions { nil }
      end
    end)

    # Should not raise, and no extra div for actions
    assert_css doc, "li"
  end

  def test_raises_when_title_and_trigger_both_set
    assert_raises(ArgumentError) do
      sp_timeline do |t|
        t.event do |e|
          e.title { "Title" }
          e.trigger { "Trigger" }
        end
      end
    end
  end

  def test_raises_when_detail_set_without_trigger
    assert_raises(ArgumentError) do
      sp_timeline do |t|
        t.event do |e|
          e.title { "Title" }
          e.detail { "Detail content" }
        end
      end
    end
  end

  def test_interactive_adds_data_controller_to_ol
    doc = parse_html(sp_timeline(interactive: true) { "" })

    assert_css doc, "ol[data-controller='timeline']"
  end

  def test_interactive_adds_data_timeline_target_item_to_li
    doc = parse_html(sp_timeline(interactive: true) do |t|
      t.event { |_e| }
    end)

    assert_css doc, "li[data-timeline-target='item']"
  end
end
