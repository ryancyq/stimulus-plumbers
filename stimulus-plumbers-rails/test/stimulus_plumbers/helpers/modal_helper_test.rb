# frozen_string_literal: true

require "test_helper"

class ModalHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::ModalHelper

  def test_sp_modal_renders_the_native_dialog_builder
    doc = parse_html(sp_modal(id: "example", title: "Example") { |_modal| nil })

    assert_css doc, "div[data-controller~='modal'] > dialog#example"
  end

  def test_sp_modal_yields_the_builder_for_trigger_and_content
    html = sp_modal(id: "example", title: "Example") do |modal|
      modal.trigger { "Open" }
      modal.body { "Body" }
    end

    assert_includes parse_html(html).text, "Open"
    assert_includes parse_html(html).text, "Body"
  end

  def test_sp_modal_turbo_delegates_to_the_turbo_modal_renderer
    doc = parse_html(sp_modal_turbo(id: "modal"))

    assert_css doc, "div[data-controller~='modal-turbo'] turbo-frame#modal"
  end

  def test_sp_modal_link_targets_the_turbo_modal_and_preserves_data
    doc = parse_html(
      sp_modal_link_to("Edit", url: "/projects/1/edit", modal_id: "modal", data: { action: "audit#open", testid: "link" })
    )
    link = doc.at_css("a")

    assert_equal "modal", link["data-turbo-frame"]
    assert_includes link["data-action"].split, "audit#open"
    assert_equal "link", link["data-testid"]
  end

  def test_sp_modal_link_supports_a_block
    assert_includes parse_html(sp_modal_link_to(url: "/edit", modal_id: "modal") { "Block link" }).text, "Block link"
  end

  def test_sp_modal_link_forces_the_frame_for_all_web_key_spellings
    %i[turbo_frame].each do |key|
      doc = parse_html(sp_modal_link_to("Edit", url: "/edit", modal_id: "modal", data: { key => "other" }))

      assert_equal "modal", doc.at_css("a")["data-turbo-frame"]
    end
    %w[turbo_frame turbo-frame].each do |key|
      doc = parse_html(sp_modal_link_to("Edit", url: "/edit", modal_id: "modal", data: { key => "other" }))

      assert_equal "modal", doc.at_css("a")["data-turbo-frame"]
    end
  end

  def test_sp_modal_link_removes_the_frame_for_all_native_key_spellings
    define_singleton_method(:hotwire_native_app?) { true }
    [:turbo_frame, "turbo_frame", "turbo-frame"].each do |key|
      doc = parse_html(sp_modal_link_to("Edit", url: "/edit", modal_id: "modal", data: { key => "other" }))

      assert_nil doc.at_css("a")["data-turbo-frame"]
    end
  end

  def test_sp_modal_link_treats_false_hotwire_native_as_web
    define_singleton_method(:hotwire_native_app?) { false }
    doc = parse_html(sp_modal_link_to("Edit", url: "/edit", modal_id: "modal"))

    assert_equal "modal", doc.at_css("a")["data-turbo-frame"]
  end

  def test_sp_modal_link_validates_modal_id
    assert_raises(ArgumentError) { sp_modal_link_to("Edit", url: "/edit", modal_id: " ") }
  end

  def test_sp_modal_link_is_normal_navigation_for_hotwire_native
    define_singleton_method(:hotwire_native_app?) { true }
    doc = parse_html(
      sp_modal_link_to("Edit", url: "/edit", modal_id: "modal", data: { "turbo-frame" => "other", testid: "link" })
    )
    link = doc.at_css("a")

    assert_nil link["data-turbo-frame"]
    assert_equal "link", link["data-testid"]
  end
end
