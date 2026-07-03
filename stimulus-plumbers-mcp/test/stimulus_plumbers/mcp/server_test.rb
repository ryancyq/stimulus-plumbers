# frozen_string_literal: true

require_relative "../../test_helper"

# Integration: drive tools through the built MCP server (not the loaders directly),
# which is the path that exercises define_tool block scope.
class ServerTest < Minitest::Test
  TOOL_ARGS = {
    "list_components"         => {},
    "get_component_schema"    => { name: "button" },
    "list_controller_docs"    => {},
    "get_controller_docs"     => { name: "modal" },
    "get_field_as_values"     => { builder_method: "field" },
    "get_field_as_controller" => { as: "select" },
    "get_component_examples"  => { name: "card" },
    "get_component_helper"    => { name: "button" },
    "list_component_docs"     => {},
    "list_controllers"        => {},
    "get_controller_schema"   => { name: "input-combobox" },
    "get_component_theme"     => { name: "button" },
    "get_component_tailwind"  => { name: "button" },
    "get_source_versions"     => {},
    "list_icons"              => {},
    "list_component_themes"   => {},
    "list_component_tailwind" => {},
    "list_guides"             => {},
    "get_guide"               => { name: "component" }
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

  # Catches a new tool shipping without test coverage.
  def test_tool_args_covers_every_registered_tool
    registered = @server.instance_variable_get(:@tools).keys
    missing = registered - TOOL_ARGS.keys

    assert_empty missing,
                 "new tool(s) #{missing.inspect} registered but missing from TOOL_ARGS " \
                 "— add sample args so it's covered by test_every_tool_invokes_without_internal_error"
  end

  def test_get_component_schema_returns_params_and_controllers
    data = JSON.parse(call_tool("get_component_schema", { name: "combobox" }).dig("result", "content", 0, "text"))

    assert data.key?("controllers"), "expected controllers key in #{data.inspect}"
    assert_includes data["controllers"], "input-combobox"
  end

  def test_versions_sources_resource_matches_get_source_versions_tool
    request = { jsonrpc: "2.0", id: 1, method: "resources/read", params: { uri: "versions://sources" } }
    response = JSON.parse(@server.handle_json(JSON.generate(request)))
    resource_data = JSON.parse(response.dig("result", "contents", 0, "text"))

    tool_data = JSON.parse(call_tool("get_source_versions").dig("result", "content", 0, "text"))

    assert_equal tool_data, resource_data
    assert resource_data.key?("component_schema")
    assert resource_data.dig("controller_schema", "version")
  end

  SHARED_SCHEME_URIS = {
    "component://button/schema"          => "application/json",
    "component://button/docs"            => "text/markdown",
    "component://button/helper"          => "application/json",
    "component://button/theme"           => "application/json",
    "component://button/tailwind"        => "application/json",
    "controller://input-combobox/schema" => "application/json",
    "controller://docs/combobox"         => "text/markdown"
  }.freeze

  def read_resource(uri)
    request = { jsonrpc: "2.0", id: 1, method: "resources/read", params: { uri: uri } }
    JSON.parse(@server.handle_json(JSON.generate(request)))
  end

  def test_shared_scheme_routes_to_the_right_plugin_per_facet
    SHARED_SCHEME_URIS.each do |uri, expected_mime|
      content = read_resource(uri).dig("result", "contents", 0)

      refute_nil content, "#{uri} returned no content"
      assert_equal expected_mime, content["mimeType"], "#{uri} routed to the wrong plugin"
    end
  end

  def test_unknown_resource_uri_returns_structured_error
    request = { jsonrpc: "2.0", id: 1, method: "resources/read", params: { uri: "guide://nope" } }
    response = JSON.parse(@server.handle_json(JSON.generate(request)))

    payload = JSON.parse(response.dig("result", "contents", 0, "text"))

    assert payload.key?("error"), "expected structured error, got #{payload.inspect}"
    assert_includes payload["error"], "guide://overview"
  end

  # Catches a new static resource whose read(uri) case was forgotten.
  def test_every_static_resource_is_readable
    @server.instance_variable_get(:@resources).each do |resource|
      content = read_resource(resource.uri).dig("result", "contents", 0)

      refute_nil content, "#{resource.uri} returned no content"
      payload = parse_json(content["text"])

      refute payload.is_a?(Hash) && payload["error"]&.start_with?("unknown resource"),
             "#{resource.uri} is registered but read() doesn't handle it: #{payload}"
    end
  end

  def parse_json(text)
    JSON.parse(text)
  rescue JSON::ParserError
    nil
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

  # Free-string tools route not-found through Base#not_found. (get_field_as_values is
  # enum-validated by the MCP gem, so its bad input never reaches the block.)
  UNKNOWN_ARGS = {
    "get_component_schema"   => { name: "nope" },
    "get_controller_schema"  => { name: "nope" },
    "get_controller_docs"    => { name: "nope" },
    "get_component_theme"    => { name: "nope" },
    "get_component_tailwind" => { name: "nope" },
    "get_component_helper"   => { name: "nope" },
    "get_component_examples" => { name: "nope" }
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
