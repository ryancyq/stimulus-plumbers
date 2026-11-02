# frozen_string_literal: true

require "test_helper"

module PopoverTestHelpers
  def renderer
    StimulusPlumbers::Components::Popover.new(self)
  end

  def render_popover(...)
    renderer.render(...)
  end

  def with_popover_theme
    original = StimulusPlumbers.config.theme.current
    StimulusPlumbers.config.theme.use(popover_test_theme)
    yield
  ensure
    StimulusPlumbers.config.theme.use(original)
  end

  def popover_test_theme
    Class.new(StimulusPlumbers::Themes::Base) do
      def popover_wrapper_classes(**)
        {}
      end

      def popover_trigger_classes(**)
        {}
      end

      def popover_classes(placement:)
        { classes: placement.to_s }
      end
    end.new
  end
end

class PopoverComponentTest < ActionView::TestCase
  include PopoverTestHelpers

  def test_exposes_template_and_theme
    popover = renderer

    assert_equal self, popover.template
    assert_equal StimulusPlumbers.config.theme.current, popover.theme
  end

  def test_renders_controller_wrapper_and_forwards_options
    doc = parse_html(render_popover(id: "wrapper", class: "dropdown", data: { testid: "popover" }))
    wrapper = doc.at_css("div[data-controller]")

    assert_equal "wrapper", wrapper["id"]
    assert_includes wrapper["class"], "dropdown"
    assert_includes wrapper["data-controller"].split, "popover"
    assert_equal "popover", wrapper["data-testid"]
  end

  def test_generated_panel_id_uses_template_dom_id_and_panel_id_for
    seen = []
    doc = render_generated_popover(seen)
    trigger = doc.at_css("button")
    panel = doc.at_css("[data-popover-target='panel']")

    assert_equal "record_popover", panel["id"]
    assert_equal "record_popover", trigger["popovertarget"]
    assert_equal ["record"], seen
  end

  def render_generated_popover(seen)
    stub(:sp_dom_id, "record") do
      StimulusPlumbers::Components::Popover.stub(:panel_id_for, ->(id) { record_panel_id(seen, id) }) do
        html = render_popover do |popover|
          popover.trigger { "Open" }
          popover.panel { "Content" }
        end
        parse_html(html)
      end
    end
  end

  def record_panel_id(seen, id)
    seen << id
    "#{id}_popover"
  end

  def test_caller_panel_id_and_wrapper_id_are_independent
    doc = parse_html(
      render_popover(id: "wrapper", panel_id: "stable-panel") do |popover|
        popover.trigger { "Open" }
        popover.panel { "Content" }
      end
    )
    wrapper = doc.at_css("div[data-controller]")
    trigger = doc.at_css("button")
    panel = doc.at_css("[data-popover-target='panel']")

    assert_equal "wrapper", wrapper["id"]
    assert_equal "stable-panel", trigger["popovertarget"]
    assert_equal "stable-panel", panel["id"]
  end

  def test_trigger_and_panel_content_are_rendered_in_order
    html = render_popover do |popover|
      popover.trigger { "Open" }
      popover.panel { "Content" }
    end

    assert_includes html, "Open"
    assert_includes html, "Content"
    assert_operator html.index("Open"), :<, html.index("Content")
  end
end

class PopoverTriggerTest < ActionView::TestCase
  include PopoverTestHelpers

  def test_packaged_trigger_uses_native_activation_without_stimulus_toggle
    trigger = parse_html(
      render_popover(panel_id: "panel") { |popover| popover.trigger { "Open" } }
    ).at_css("button")

    assert_equal "button", trigger["type"]
    assert_equal "panel", trigger["popovertarget"]
    assert_equal "trigger", trigger["data-popover-target"]
    assert_nil trigger["data-action"]
  end

  def test_packaged_trigger_forwards_controls_override
    trigger = parse_html(
      render_popover(panel_id: "panel") do |popover|
        popover.trigger(haspopup: :listbox, controls: "options") { "Open" }
      end
    ).at_css("button")

    assert_equal "options", trigger["aria-controls"]
    assert_equal "listbox", trigger["aria-haspopup"]
    assert_equal "false", trigger["aria-expanded"]
  end

  def test_packaged_trigger_omits_semantics_by_default
    trigger = parse_html(
      render_popover(panel_id: "panel") { |popover| popover.trigger { "Open" } }
    ).at_css("button")

    assert_nil trigger["aria-haspopup"]
    assert_nil trigger["aria-expanded"]
    assert_nil trigger["aria-controls"]
  end

  def test_custom_trigger_receives_relationship_semantics_and_caller_options
    received = custom_trigger_attributes

    assert_equal "panel", received[:panel_id]
    assert_equal :listbox, received.dig(:aria, :haspopup)
    assert_equal "false", received.dig(:aria, :expanded)
    assert_equal "options", received.dig(:aria, :controls)
  end

  def test_custom_trigger_forwards_target_and_caller_options_without_action
    received = custom_trigger_attributes

    assert_equal "trigger", received.dig(:data, :popover_target)
    assert_nil received.dig(:data, :action)
    assert_includes received[:class], "custom"
    assert_equal "trigger", received.dig(:data, :testid)
  end

  def custom_trigger_attributes
    received = nil
    render_popover(panel_id: "panel") do |popover|
      popover.trigger(haspopup: :listbox, controls: "options", class: "custom", data: { testid: "trigger" }) do |attrs|
        received = attrs
        content_tag(:input, **attrs.except(:panel_id))
      end
    end
    received
  end

  def test_custom_trigger_omits_semantics_when_haspopup_is_not_supplied
    received = nil
    render_popover do |popover|
      popover.trigger do |attrs|
        received = attrs
        "Custom"
      end
    end

    assert_nil received[:aria]
    assert_equal "trigger", received.dig(:data, :popover_target)
    assert_nil received.dig(:data, :action)
  end
end

class PopoverPanelTest < ActionView::TestCase
  include PopoverTestHelpers

  def test_panel_renders_native_attributes
    panel = panel_with_options

    assert_equal "panel", panel["id"]
    assert_equal "auto", panel["popover"]
    assert_nil panel["hidden"]
  end

  def test_panel_forwards_semantics_and_custom_options
    panel = panel_with_options

    assert_equal "menu", panel["role"]
    assert_equal "Actions", panel["aria-label"]
    assert_equal "title", panel["aria-labelledby"]
    assert_includes panel["class"], "custom"
    assert_equal "menu#select", panel["data-action"]
    assert_equal "panel", panel["data-testid"]
  end

  def panel_with_options
    parse_html(
      render_popover(panel_id: "panel") do |popover|
        popover.panel(
          role:            :menu,
          aria_label:      "Actions",
          aria_labelledby: "title",
          class:           "custom",
          data:            { action: "menu#select", testid: "panel" }
        ) { "Content" }
      end
    ).at_css("[data-popover-target='panel']")
  end

  def test_manual_mode_is_rendered_on_panel
    panel = parse_html(
      render_popover(mode: :manual) { |popover| popover.panel { "Content" } }
    ).at_css("[data-popover-target='panel']")

    assert_equal "manual", panel["popover"]
  end

  def test_only_mode_is_validated
    assert_raises(ArgumentError) { render_popover(mode: :dialog) }
  end

  def test_unknown_placement_warns_and_uses_theme_default
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{popover#placement received unknown value :sideways}])

    with_popover_theme do
      Rails.stub(:logger, mock_logger) do
        panel = parse_html(
          render_popover(placement: :sideways) { |popover| popover.panel { "Content" } }
        ).at_css("[data-popover-target='panel']")

        assert_equal "block_end_start", panel["class"]
      end
    end
    mock_logger.verify
  end
end

class PopoverBuildTest < ActionView::TestCase
  include PopoverTestHelpers

  def test_build_returns_native_content_without_wrapper
    doc = parse_html(
      renderer.build(panel_id: "panel") do |popover|
        popover.trigger { "Open" }
        popover.panel { "Content" }
      end
    )

    assert_no_css doc, "[data-controller~='popover']"
    assert_css doc, "button[popovertarget='panel']"
    assert_css doc, "[data-popover-target='panel'][popover='auto']"
  end

  def test_reused_renderer_reestablishes_defaults_for_build_and_render
    with_popover_theme do
      reused = renderer
      manual_panel = rendered_panel(reused, mode: :manual, placement: :inline_end)
      default_build_panel = built_panel(reused)
      default_render_panel = rendered_panel(reused)

      assert_panel_state manual_panel, "manual", "inline_end"
      assert_panel_state default_build_panel, "auto", "block_end_start"
      assert_panel_state default_render_panel, "auto", "block_end_start"
    end
  end

  def assert_panel_state(panel, mode, placement)
    assert_equal mode, panel["popover"]
    assert_equal placement, panel["class"]
  end

  def rendered_panel(reused, **options)
    panel_from(reused.render(**options) { |popover| popover.panel { "Content" } })
  end

  def built_panel(reused)
    panel_from(reused.build { |popover| popover.panel { "Content" } })
  end

  def panel_from(html)
    parse_html(html).at_css("[data-popover-target='panel']")
  end
end
