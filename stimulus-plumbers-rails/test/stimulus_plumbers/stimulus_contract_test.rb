# frozen_string_literal: true

require "test_helper"
require "json"

class StimulusContractTest < Minitest::Test
  COMPONENT_MANIFEST_PATH  = File.expand_path("../../vendor/component/manifest.json", __dir__)
  CONTROLLER_MANIFEST_PATH = File.expand_path("../../../stimulus-plumbers/dist/controllers.manifest.json", __dir__)

  # Pre-existing drift found when this test was introduced — not caused by this change.
  # Tracked separately; remove each entry here once it's fixed for real.
  KNOWN_VIOLATIONS = {}.freeze

  def setup
    unless File.exist?(COMPONENT_MANIFEST_PATH) && File.exist?(CONTROLLER_MANIFEST_PATH)
      raise "missing manifest — run `npm run build` in stimulus-plumbers/ and `rake build:manifest` here first"
    end

    @component  = JSON.parse(File.read(COMPONENT_MANIFEST_PATH))
    @controller = JSON.parse(File.read(CONTROLLER_MANIFEST_PATH))

    return if @controller.each_value.all? { |data| data.key?("actionParams") }

    raise "controller manifest predates actionParams — re-run `npm run build` in stimulus-plumbers/"
  end

  def test_every_referenced_identifier_exists_in_js
    @component.each_key do |id|
      assert @controller.key?(id), "Ruby references controller `#{id}` which does not exist in controllers.manifest.json"
    end
  end

  def test_every_ruby_action_exists_as_a_js_method
    @component.each do |id, wiring|
      wiring["actions"].each do |method|
        assert_includes @controller[id]["actions"],
                        method,
                        "Ruby wires `#{id}##{method}` but the JS controller has no such method"
      end
    end
  end

  # Stimulus passes the Event as arg 1, so a data-action may only name an onX(event)
  # adapter or a method that ignores its arguments — never `select(value)`.
  def test_every_ruby_action_is_an_event_adapter
    @component.each do |id, wiring|
      wiring["actions"].each do |method|
        params = @controller[id]["actionParams"][method]
        next if params.nil? || params.empty?

        assert_equal "event",
                     params.first,
                     "Ruby wires `#{id}##{method}` but it takes `#{params.first}`, not an event — " \
                     "wire an onX(event) adapter instead of calling the programmatic API directly"
      end
    end
  end

  def test_every_ruby_listened_event_is_dispatched_by_js
    @component.each do |id, wiring|
      wiring["listens"].each do |event|
        assert_includes @controller[id]["dispatches"],
                        event,
                        "Ruby listens for `#{id}:#{event}` but the JS controller never dispatches it"
      end
    end
  end

  def test_every_ruby_target_exists_in_js
    @component.each do |id, wiring|
      wiring["targets"].each do |target|
        next if known_violation?(id, "targets", target)

        assert_includes @controller[id]["targets"],
                        target,
                        "Ruby references target `#{id}##{target}` which is not declared in the JS controller"
      end
    end
  end

  def test_every_ruby_value_exists_in_js
    @component.each do |id, wiring|
      wiring["values"].each do |value|
        next if known_violation?(id, "values", value)

        assert_includes @controller[id]["values"].keys,
                        value,
                        "Ruby references value `#{id}.#{value}Value` which is not declared in the JS controller"
      end
    end
  end

  private

  def known_violation?(id, category, name)
    KNOWN_VIOLATIONS.dig(id, category)&.include?(name) || false
  end
end
