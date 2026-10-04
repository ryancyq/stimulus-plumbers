# frozen_string_literal: true

require "test_helper"

module ModalTestHelpers
  def renderer
    StimulusPlumbers::Components::Modal.new(self)
  end

  def render_modal(**options, &block)
    renderer.render(id: "example", title: "Example", **options, &block)
  end
end

class ModalTest < ActionView::TestCase
  include ModalTestHelpers

  def test_renders_controller_wrapper_and_native_dialog
    doc = parse_html(render_modal)

    assert_css doc, "div[data-controller~='modal'] > dialog#example[data-modal-target='dialog']"
    assert_no_css doc, "[aria-modal]"
  end

  def test_renders_generated_title_and_relationship
    doc = parse_html(render_modal)

    assert_css doc, "dialog[aria-labelledby='example-title'] > header > h2#example-title"
    assert_equal "Example", doc.at_css("h2#example-title").text
  end

  def test_aria_label_is_used_without_title
    doc = parse_html(renderer.render(id: "example", aria_label: "Example dialog"))

    assert_css doc, "dialog[aria-label='Example dialog']"
    assert_no_css doc, "dialog[aria-labelledby]"
    assert_no_css doc, "h2"
  end

  def test_title_takes_precedence_over_aria_label
    doc = parse_html(render_modal(aria_label: "Ignored"))

    assert_css doc, "dialog[aria-labelledby='example-title']"
    assert_no_css doc, "dialog[aria-label]"
  end

  def test_alertdialog_adds_only_alertdialog_role
    assert_css parse_html(render_modal(kind: :alertdialog)), "dialog[role='alertdialog']"
    assert_no_css parse_html(render_modal), "dialog[role]"
  end

  def test_renders_closedby_policy_and_default
    assert_css parse_html(render_modal(closed_by: :any)), "dialog[closedby='any']"
    assert_css parse_html(render_modal), "dialog[closedby='closerequest']"
  end

  def test_forwards_wrapper_html_options_without_losing_controller
    doc = parse_html(render_modal(id: "example", class: "custom", data: { testid: "modal" }))
    wrapper = doc.at_css("div[data-controller]")

    assert_includes wrapper["class"], "custom"
    assert_includes wrapper["data-controller"].split, "modal"
    assert_equal "modal", wrapper["data-testid"]
  end

  def test_validates_required_semantics
    assert_raises(ArgumentError) { renderer.render(id: "example") }
    assert_raises(ArgumentError) { renderer.render(id: " ", title: "Example") }
    assert_raises(ArgumentError) { render_modal(closed_by: :later) }
    assert_raises(ArgumentError) { render_modal(kind: :dialogish) }
  end
end

class ModalSlotsTest < ActionView::TestCase
  include ModalTestHelpers

  def test_renders_slots_in_order
    doc = parse_html(
      render_modal do |modal|
        modal.trigger { "Open" }
        modal.header { content_tag(:span, "Header") }
        modal.body { content_tag(:p, "Body") }
        modal.footer { content_tag(:span, "Footer") }
      end
    )

    assert_css doc, "div[data-controller] > button + dialog"
    assert_css doc, "dialog > header + div + footer"
  end

  def test_does_not_duplicate_captured_slots
    doc = parse_html(
      render_modal do |modal|
        modal.header { content_tag(:span, "Header") }
        modal.body { "Body" }
        modal.footer { "Footer" }
      end
    )

    assert_equal "Header", doc.at_css("header span").text
    assert_equal "Body", doc.at_css("dialog > div").text
    assert_equal "Footer", doc.at_css("dialog > footer").text
  end

  def test_header_body_and_footer_require_blocks
    assert_raises(ArgumentError) { render_modal(&:header) }
    assert_raises(ArgumentError) { render_modal(&:body) }
    assert_raises(ArgumentError) { render_modal(&:footer) }
  end
end

class ModalTriggerTest < ActionView::TestCase
  include ModalTestHelpers

  def test_trigger_has_command_enhancement_and_stimulus_fallback
    trigger = parse_html(render_modal { |modal| modal.trigger { "Open" } }).at_css("button")

    assert_equal "button", trigger["type"]
    assert_equal "example", trigger["commandfor"]
    assert_equal "show-modal", trigger["command"]
    assert_equal "modal#open", trigger["data-action"]
    assert_nil trigger["aria-expanded"]
  end

  def test_packaged_trigger_preserves_caller_data_and_actions
    doc = parse_html(
      render_modal { |modal| modal.trigger(data: { action: "audit#open", testid: "trigger" }) { "Open" } }
    )
    trigger = doc.at_css("button")

    assert_includes trigger["data-action"].split, "audit#open"
    assert_includes trigger["data-action"].split, "modal#open"
    assert_equal "trigger", trigger["data-testid"]
  end

  def test_custom_trigger_receives_complete_attributes
    received = nil
    render_modal do |modal|
      modal.trigger do |attrs|
        received = attrs
        content_tag(:button, "Open", **attrs)
      end
    end

    assert_equal "button", received[:type]
    assert_equal "example", received[:commandfor]
    assert_equal "show-modal", received[:command]
    assert_equal "modal#open", received.dig(:data, :action)
  end

  def test_custom_trigger_preserves_caller_data_and_actions
    received = nil
    render_modal do |modal|
      modal.trigger(data: { action: "audit#open", testid: "trigger" }) do |attrs|
        received = attrs
        content_tag(:button, "Open", **attrs)
      end
    end

    assert_includes received[:data][:action].split, "audit#open"
    assert_includes received[:data][:action].split, "modal#open"
    assert_equal "trigger", received[:data][:testid]
  end
end

class ModalButtonTest < ActionView::TestCase
  include ModalTestHelpers

  def test_buttons_wire_dismiss_and_close_results
    doc = parse_html(
      render_modal do |modal|
        modal.footer do
          safe_join(
            [
              modal.dismiss_button("Cancel", result: "cancel"),
              modal.close_button("Delete", result: "delete", variant: :destructive)
            ]
          )
        end
      end
    )

    assert_button_result_markup doc
  end

  def test_close_button_result_is_optional
    doc = parse_html(
      render_modal do |modal|
        modal.footer do
          safe_join([modal.dismiss_button("Cancel"), modal.close_button("Close")])
        end
      end
    )

    assert_css doc, "button[commandfor='example'][command='request-close'][data-action='modal#dismiss']"
    assert_css doc, "button[commandfor='example'][command='close'][data-action='modal#close']"
    assert_equal 0, doc.css("button[data-modal-result-param], button[value]").length
  end

  def test_action_button_preserves_caller_data_and_actions
    doc = parse_html(
      render_modal do |modal|
        modal.footer do
          modal.dismiss_button("Cancel", data: { action: "audit#cancel", testid: "cancel" })
        end
      end
    )
    button = doc.at_css("button[data-action]")

    assert_includes button["data-action"].split, "audit#cancel"
    assert_includes button["data-action"].split, "modal#dismiss"
    assert_button_command button, "request-close"
    assert_equal "cancel", button["data-testid"]
  end

  def test_modal_wiring_takes_precedence_over_caller_button_attributes
    html = render_modal do |modal|
      modal.footer do
        modal.dismiss_button(
          "Cancel", result: "cancel", commandfor: "other", command: "show-modal", value: "caller-result"
        )
      end
    end

    assert_button_command parse_html(html).at_css("button"), "request-close", "cancel"
  end

  private

  def assert_button_result_markup(doc)
    assert_button_command doc.at_css("button[data-action='modal#dismiss']"), "request-close", "cancel"
    assert_button_command doc.at_css("button[data-action='modal#close']"), "close", "delete"
    assert_css doc, "button[data-action='modal#dismiss'][data-modal-result-param='cancel']"
    assert_css doc, "button[data-action='modal#close'][data-modal-result-param='delete']"
  end

  def assert_button_command(button, command, value = nil)
    assert_equal "example", button["commandfor"]
    assert_equal command, button["command"]
    assert_equal value, button["value"] if value
  end
end
