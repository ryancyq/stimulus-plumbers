# frozen_string_literal: true

require "test_helper"
require "json"
require_relative "../../../tasks/support/component_manifest"

class ComponentManifestTest < Minitest::Test
  JS_MANIFEST_PATH = File.expand_path("../../../../stimulus-plumbers/dist/controllers.manifest.json", __dir__)

  # calendar-month covers constant-interpolated identifiers (calendar.rb's
  # MONTH_STIMULUS_CONTROLLER); combobox-date must also be known for the
  # "calendar-month:selected->combobox-date#onDaySelect" binding to register
  # (the listen source only registers once its target resolves); modal is
  # wired by the modal helper's generated action.
  KNOWN_IDS = %w[popover reorderable calendar-month combobox-date modal modal-turbo].freeze

  def setup
    @result = StimulusPlumbers::ComponentManifest.call(known_identifiers: KNOWN_IDS)
  end

  # Guards KNOWN_IDS against drift from the real JS controllers.
  def test_known_ids_are_real_js_controllers
    skip "run `npm run build` in stimulus-plumbers/ first" unless File.exist?(JS_MANIFEST_PATH)

    js_ids = JSON.parse(File.read(JS_MANIFEST_PATH)).keys
    missing = KNOWN_IDS - js_ids

    assert_empty missing, "KNOWN_IDS references controllers no longer in controllers.manifest.json: #{missing}"
  end

  def test_extracts_method_actions
    assert_includes @result["popover"]["actions"], "open"
    assert_includes @result["popover"]["actions"], "toggle"
  end

  def test_extracts_dispatch_listens
    assert_includes @result["calendar-month"]["listens"], "selected"
  end

  # "calendar-month:selected->combobox-date#onDaySelect" — both halves must be recorded.
  def test_extracts_actions_wired_from_a_custom_event
    assert_includes @result["combobox-date"]["actions"], "onDaySelect"
  end

  def test_extracts_targets
    assert_includes @result["reorderable"]["targets"], "item"
    assert_includes @result["reorderable"]["targets"], "handle"
  end

  def test_extracts_values_as_camel_case
    assert_includes @result["reorderable"]["values"], "moveKey"
    assert_includes @result["reorderable"]["values"], "editing"
  end

  def test_resolves_constant_interpolated_identifiers
    assert_includes @result["calendar-month"]["targets"], "daysOfWeek"
  end

  def test_extracts_modal_open_action
    assert_equal ["open"], @result["modal"]["actions"]
    assert_equal ["closed"], @result["modal"]["listens"]
    assert_equal ["dialog"], @result["modal"]["targets"]
    assert_equal [], @result["modal"]["values"]
  end

  def test_extracts_modal_turbo_wiring
    expected = {
      "actions" => %w[onBeforeFetchRequest onClosed onFrameRender onSubmitEnd],
      "listens" => [],
      "targets" => ["frame"],
      "values"  => ["closeOnSuccess"]
    }

    assert_equal expected, @result["modal-turbo"]
  end
end
