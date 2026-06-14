# frozen_string_literal: true

require_relative "../../test_helper"

# Integration: drive tools through the built MCP server (not the loaders directly),
# which is the path that exercises define_tool block scope.
class ServerTest < Minitest::Test
  TOOL_ARGS = {
    "list_components"       => {},
    "get_component_schema"  => { component: "button" },
    "get_field_types"       => { builder_method: "field" },
    "get_erb_examples"      => { component: "card" },
    "get_helper_signature"  => { component: "button" },
    "list_docs"             => {},
    "list_controllers"      => {},
    "get_controller_schema" => { controller: "input-combobox" },
    "get_theme_interface"   => { component: "button" },
    "get_tailwind_classes"  => { component: "button" }
  }.freeze

  def setup
    @server = StimulusPlumbers::MCP::Server.build
  end

  def call_tool(name, arguments = {})
    request = { jsonrpc: "2.0", id: 1, method: "tools/call", params: { name: name, arguments: arguments } }
    JSON.parse(@server.handle_json(JSON.generate(request)))
  end

  def test_every_tool_invokes_without_internal_error
    TOOL_ARGS.each do |name, args|
      response = call_tool(name, args)

      refute response.key?("error"), "#{name} errored: #{response["error"].inspect}"
    end
  end

  def test_get_component_schema_returns_params_and_controllers
    data = JSON.parse(call_tool("get_component_schema", { component: "combobox" }).dig("result", "content", 0, "text"))

    assert data.key?("controllers"), "expected controllers key in #{data.inspect}"
    assert_includes data["controllers"], "input-combobox"
  end

  def test_report_sources_warns_on_empty_source
    assert_output(nil, %r{source 'docs' is empty}) do
      StimulusPlumbers::MCP::Server.report_sources({ docs: {}, schema: { a: 1 } })
    end
  end

  def test_report_sources_warns_when_schema_components_empty
    # schema/theme use a wrapper hash; empty_source? must inspect :components, not the wrapper
    assert_output(nil, %r{source 'schema' is empty}) do
      StimulusPlumbers::MCP::Server.report_sources({ schema: { components: {}, field_as: {} }, docs: { button: {} } })
    end
  end

  # Free-string tools route not-found through Base#not_found. (get_field_types is
  # enum-validated by the MCP gem, so its bad input never reaches the block.)
  UNKNOWN_ARGS = {
    "get_component_schema"  => { component: "nope" },
    "get_controller_schema" => { controller: "nope" },
    "get_theme_interface"   => { component: "nope" },
    "get_tailwind_classes"  => { component: "nope" },
    "get_helper_signature"  => { component: "nope" },
    "get_erb_examples"      => { component: "nope" }
  }.freeze

  def test_unknown_arguments_return_uniform_structured_errors
    UNKNOWN_ARGS.each do |name, args|
      result = call_tool(name, args).fetch("result")

      assert result["isError"], "#{name} should set isError on not-found"
      payload = JSON.parse(result.dig("content", 0, "text"))

      assert payload.key?("error"), "#{name} error payload should have an 'error' key, got #{payload.inspect}"
    end
  end
end
