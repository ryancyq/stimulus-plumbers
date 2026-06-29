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
    doc = parse_html(
      sp_timeline do |t|
        t.event(datetime: "2024-01-15")
        t.event(datetime: "2024-03-01")
      end
    )

    assert_equal 2, doc.css("li").size
  end

  def test_renders_indicator_dot_when_indicator_called
    doc = parse_html(
      sp_timeline do |t|
        t.event(&:with_indicator)
      end
    )

    assert_css doc, "li div[aria-hidden='true']"
  end

  def test_renders_icon_indicator_when_icon_given
    doc = parse_html(
      sp_timeline do |t|
        t.event do |e|
          e.with_indicator(icon: "check")
        end
      end
    )

    assert_css doc, "li div[aria-hidden='true']"
  end

  def test_renders_time_with_datetime_attribute_and_time_slot
    doc = parse_html(
      sp_timeline do |t|
        t.event(datetime: "2024-01-15") do |e|
          e.with_time { "January 2024" }
        end
      end
    )

    assert_css doc, "time[datetime='2024-01-15']"
    assert_includes doc.css("time").text, "January 2024"
  end

  def test_renders_time_element_when_datetime_given_without_time_slot
    doc = parse_html(
      sp_timeline do |t|
        t.event(datetime: "2024-01-15")
      end
    )

    assert_css doc, "time[datetime='2024-01-15']"
    assert_equal "", doc.css("time").text.strip
  end

  def test_omits_time_element_when_neither_datetime_nor_time_slot_given
    doc = parse_html(
      sp_timeline(&:event)
    )

    assert_equal 0, doc.css("time").size
  end

  def test_raises_when_time_slot_given_without_datetime
    assert_raises(ArgumentError, "e.time requires datetime:") do
      sp_timeline do |t|
        t.event do |e|
          e.with_time { "January 2024" }
        end
      end
    end
  end

  def test_renders_static_h3_with_title
    doc = parse_html(
      sp_timeline do |t|
        t.event do |e|
          e.with_title { "Event title" }
        end
      end
    )

    assert_css doc, "h3"
    assert_includes doc.css("h3").text, "Event title"
  end

  def test_renders_h3_with_button_for_trigger
    doc = parse_html(
      sp_timeline do |t|
        t.event do |e|
          e.with_trigger { "Event title" }
        end
      end
    )

    assert_css doc, "h3 button"
    assert_includes doc.css("h3 button").text, "Event title"
  end

  def test_detail_id_matches_trigger_aria_controls
    doc = parse_html(
      sp_timeline(interactive: true) do |t|
        t.event do |e|
          e.with_trigger { "Event title" }
          e.with_detail { "Expanded content" }
        end
      end
    )

    controls_id = doc.css("button[aria-controls]").first["aria-controls"]

    assert_not_nil controls_id
    assert_css doc, "div[id='#{controls_id}']"
    assert_css doc, "div[hidden]"
    assert_css doc, "div[data-timeline-target='detail']"
  end

  def test_explicit_id_produces_deterministic_detail_id
    doc = parse_html(
      sp_timeline(interactive: true) do |t|
        t.event(id: "event-1") do |e|
          e.with_trigger { "Event title" }
          e.with_detail { "Expanded content" }
        end
      end
    )

    assert_css doc, "button[aria-controls='event-1_detail']"
    assert_css doc, "div[id='event-1_detail']"
  end

  def test_renders_p_for_description
    doc = parse_html(
      sp_timeline do |t|
        t.event do |e|
          e.with_description { "Brief description" }
        end
      end
    )

    assert_css doc, "p"
    assert_includes doc.css("p").text, "Brief description"
  end

  def test_renders_actions_wrapper_when_block_has_content
    doc = parse_html(
      sp_timeline do |t|
        t.event do |e|
          e.with_actions { "Read more" }
        end
      end
    )

    assert_css doc, "li div"
    assert_includes doc.text, "Read more"
  end

  def test_suppresses_actions_wrapper_when_block_is_empty
    doc = parse_html(
      sp_timeline do |t|
        t.event do |e|
          e.with_title { "Title" }
          e.with_actions { nil }
        end
      end
    )

    assert_css doc, "li"
  end

  def test_raises_when_title_and_trigger_both_set
    assert_raises(ArgumentError) do
      sp_timeline do |t|
        t.event do |e|
          e.with_title { "Title" }
          e.with_trigger { "Trigger" }
        end
      end
    end
  end

  def test_raises_when_detail_set_without_trigger
    assert_raises(ArgumentError) do
      sp_timeline do |t|
        t.event do |e|
          e.with_title { "Title" }
          e.with_detail { "Detail content" }
        end
      end
    end
  end

  def test_interactive_adds_data_controller_to_ol
    doc = parse_html(sp_timeline(interactive: true) { "" })

    assert_css doc, "ol[data-controller='timeline']"
  end

  def test_with_trigger_promotes_timeline_to_interactive
    doc = parse_html(
      sp_timeline do |t|
        t.event do |e|
          e.with_trigger { "Event title" }
        end
      end
    )

    assert_css doc, "ol[data-controller='timeline']"
    assert_css doc, "h3 button"
    assert_css doc, "button[data-timeline-target='trigger']"
    assert_css doc, "button[data-action='timeline#toggle']"
    assert_css doc, "button[aria-expanded='false']"
  end

  def test_with_trigger_and_detail_promotes_interactive_and_hides_detail
    doc = parse_html(
      sp_timeline do |t|
        t.event do |e|
          e.with_trigger { "Event title" }
          e.with_detail { "Expanded content" }
        end
      end
    )

    assert_css doc, "ol[data-controller='timeline']"
    assert_css doc, "div[hidden]"
    assert_css doc, "div[data-timeline-target='detail']"
    assert_includes doc.text, "Expanded content"
  end

  def test_title_slot_without_trigger_stays_non_interactive
    doc = parse_html(
      sp_timeline do |t|
        t.event do |e|
          e.with_title { "Event title" }
        end
      end
    )

    assert_no_css doc, "ol[data-controller]"
    assert_css doc, "h3"
    assert_no_css doc, "button"
  end

  def test_multiple_events_render_without_explicit_concat
    # With only return-value capture, only the last event appears.
    doc = parse_html(
      sp_timeline do |t|
        t.event(datetime: "2024-01-15") do |e|
          e.with_title { "First event" }
        end
        t.event(datetime: "2024-03-01") do |e|
          e.with_title { "Second event" }
        end
      end
    )

    assert_equal 2, doc.css("li").size
    assert_includes doc.text, "First event"
    assert_includes doc.text, "Second event"
  end

  def test_interactive_trigger_includes_stimulus_attrs
    doc = parse_html(
      sp_timeline(interactive: true) do |t|
        t.event(id: "ev-1") do |e|
          e.with_trigger { "Event title" }
          e.with_detail { "Expanded content" }
        end
      end
    )

    assert_css doc, "button[data-timeline-target='trigger']"
    assert_css doc, "button[data-action='timeline#toggle']"
    assert_css doc, "button[aria-expanded='false']"
    assert_css doc, "button[aria-controls='ev-1_detail']"
    assert_css doc, "div[hidden]"
    assert_css doc, "div[data-timeline-target='detail']"
  end

  def test_horizontal_event_wraps_time_inside_content_div_not_direct_li_child
    doc = parse_html(
      sp_timeline(orientation: :horizontal) do |t|
        t.event(datetime: "2024-01-15") do |e|
          e.with_indicator
          e.with_time { "January 2024" }
          e.with_title { "Step one" }
        end
      end
    )

    assert_empty doc.css("li > time"), "time must not be a direct child of li in horizontal mode"
    assert_css   doc, "li time"
  end

  def test_horizontal_event_renders_connector_sibling_to_indicator
    doc = parse_html(
      sp_timeline(orientation: :horizontal) do |t|
        t.event do |e|
          e.with_indicator
          e.with_title { "Step one" }
        end
      end
    )

    li = doc.css("li").first
    direct_divs = li.children.select { |n| n.name == "div" }

    assert_operator direct_divs.size, :>=, 2, "expected indicator row + content wrapper as direct li children"
  end

  def test_vertical_event_renders_time_element
    doc = parse_html(
      sp_timeline(orientation: :vertical) do |t|
        t.event(datetime: "2024-01-15") do |e|
          e.with_time { "January 2024" }
          e.with_title { "Step one" }
        end
      end
    )

    assert_css doc, "li time", "time must be rendered inside the vertical event"
  end

  def test_group_renders_outer_div
    doc = parse_html(sp_timeline_group { "" })

    assert_css doc, "div"
  end

  def test_group_section_renders_time_with_datetime
    doc = parse_html(
      sp_timeline_group do |g|
        g.section(date: "January 2025", datetime: "2025-01-15") { "" }
      end
    )

    assert_css doc, "time[datetime='2025-01-15']"
    assert_includes doc.css("time").text, "January 2025"
  end

  def test_group_section_without_datetime_renders_time_without_attribute
    doc = parse_html(
      sp_timeline_group do |g|
        g.section(date: "January 2025") { "" }
      end
    )

    assert_css doc, "time"
    assert_empty doc.css("time[datetime]")
  end

  def test_group_section_renders_ol_for_events
    doc = parse_html(
      sp_timeline_group do |g|
        g.section(date: "January 2025") { "" }
      end
    )

    assert_css doc, "ol"
  end

  def test_group_section_events_render_as_li_elements
    doc = parse_html(
      sp_timeline_group do |g|
        g.section(date: "January 2025") do |t|
          t.event do |e|
            e.with_title { "Event one" }
          end
          t.event do |e|
            e.with_title { "Event two" }
          end
        end
      end
    )

    assert_equal 2, doc.css("li").size
    assert_includes doc.text, "Event one"
    assert_includes doc.text, "Event two"
  end

  def test_group_multiple_sections_each_have_a_date
    doc = parse_html(
      sp_timeline_group do |g|
        g.section(date: "January 2025", datetime: "2025-01-15") { "" }
        g.section(date: "February 2025", datetime: "2025-02-01") { "" }
      end
    )

    times = doc.css("time")

    assert_equal 2, times.size
    assert_includes times.map(&:text), "January 2025"
    assert_includes times.map(&:text), "February 2025"
  end

  def test_time_slot_accepts_badge_type_kwarg
    doc = parse_html(
      sp_timeline do |t|
        t.event(datetime: "2024-01-15") do |e|
          e.with_time(type: :badge) { "January 2024" }
        end
      end
    )

    assert_css doc, "time[datetime='2024-01-15']"
    assert_includes doc.css("time").text, "January 2024"
  end
end
