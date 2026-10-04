# frozen_string_literal: true

require "test_helper"

class ModalTurboTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Modal::Turbo.new(self)
  end

  def render_turbo(**options)
    renderer.render(id: "modal", **options)
  end

  def test_renders_turbo_modal_wrapper_and_native_dialog
    doc     = parse_html(render_turbo)
    wrapper = doc.at_css("div[data-controller]")

    assert_includes wrapper["data-controller"].split, "modal"
    assert_includes wrapper["data-controller"].split, "modal-turbo"
    assert_equal "true", wrapper["data-modal-turbo-close-on-success-value"]
    assert_css doc, "dialog[closedby='closerequest'][data-modal-target='dialog']"
    assert_no_css doc, "dialog[aria-modal]"
  end

  def test_renders_frame_target_and_actions
    doc   = parse_html(render_turbo)
    frame = doc.at_css("turbo-frame#modal[data-modal-turbo-target='frame']")

    assert_not_nil frame
    assert_includes frame["data-action"], "turbo:before-fetch-request->modal-turbo#onBeforeFetchRequest"
    assert_includes frame["data-action"], "turbo:frame-render->modal-turbo#onFrameRender"
    assert_includes frame["data-action"], "turbo:submit-end->modal-turbo#onSubmitEnd"
  end

  def test_preserves_wrapper_html_data_and_action_options
    doc = parse_html(
      renderer.render(
        id:    "modal",
        class: "custom-wrapper",
        data:  { action: "audit#closed", testid: "wrapper" }
      )
    )
    wrapper = doc.at_css("div[data-controller]")

    assert_includes wrapper["class"], "custom-wrapper"
    assert_includes wrapper["data-action"].split, "audit#closed"
    assert_includes wrapper["data-action"].split, "modal:closed->modal-turbo#onClosed"
    assert_equal "wrapper", wrapper["data-testid"]
  end

  def test_uses_labelledby_by_default
    assert_css parse_html(render_turbo), "dialog[aria-labelledby='modal-title']"
  end

  def test_uses_aria_label_when_supplied
    doc = parse_html(render_turbo(aria_label: "Edit project", close_on_success: false))

    assert_css doc, "dialog[aria-label='Edit project']"
    assert_no_css doc, "dialog[aria-labelledby]"
    assert_equal "false", doc.at_css("div[data-controller]")["data-modal-turbo-close-on-success-value"]
  end

  def test_validates_id_and_closed_by
    assert_raises(ArgumentError) { renderer.render(id: " ") }
    assert_raises(ArgumentError) { render_turbo(closed_by: :later) }
  end

  def test_is_blockless
    html = renderer.render(id: "modal") { "ignored" }

    refute_includes parse_html(html).text, "ignored"
  end

  def test_uses_the_standalone_renderer_and_modal_semantic_choices
    assert_equal StimulusPlumbers::Plumber::Base, renderer.class.superclass

    StimulusPlumbers::Components::Modal::CLOSED_BY.each do |closed_by|
      assert_css parse_html(render_turbo(closed_by: closed_by)), "dialog[closedby='#{closed_by}']"
    end
  end
end
