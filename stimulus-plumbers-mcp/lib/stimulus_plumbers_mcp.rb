# frozen_string_literal: true

require "json"
require "action_view/version"
require "uri" if ActionView.version < Gem::Version.new("7.3")
require "mcp"
require "action_view"
require "stimulus_plumbers"
require "stimulus_plumbers_tailwind"

require_relative "stimulus_plumbers/mcp/version"
require_relative "stimulus_plumbers/mcp/loaders/support/docs_table_parser"
require_relative "stimulus_plumbers/mcp/loaders/support/gem_vendor_path"

require_relative "stimulus_plumbers/mcp/loaders/component_docs_loader"
require_relative "stimulus_plumbers/mcp/loaders/component_requirements"
require_relative "stimulus_plumbers/mcp/loaders/component_schema_loader"
require_relative "stimulus_plumbers/mcp/loaders/component_theme_loader"

require_relative "stimulus_plumbers/mcp/loaders/controller_docs_loader"
require_relative "stimulus_plumbers/mcp/loaders/controller_schema_loader"

require_relative "stimulus_plumbers/mcp/loaders/icons_loader"
require_relative "stimulus_plumbers/mcp/loaders/tailwind_loader"

require_relative "stimulus_plumbers/mcp/loaders/aria_loader"
require_relative "stimulus_plumbers/mcp/loaders/guide_loader"
require_relative "stimulus_plumbers/mcp/loaders/versions_loader"

require_relative "stimulus_plumbers/mcp/plugins/base"

require_relative "stimulus_plumbers/mcp/plugins/component_docs"
require_relative "stimulus_plumbers/mcp/plugins/component_schema"
require_relative "stimulus_plumbers/mcp/plugins/component_theme"

require_relative "stimulus_plumbers/mcp/plugins/controller_docs"
require_relative "stimulus_plumbers/mcp/plugins/controller_schema"

require_relative "stimulus_plumbers/mcp/plugins/icons"
require_relative "stimulus_plumbers/mcp/plugins/tailwind"

require_relative "stimulus_plumbers/mcp/plugins/aria"
require_relative "stimulus_plumbers/mcp/plugins/guide"
require_relative "stimulus_plumbers/mcp/plugins/versions"

require_relative "stimulus_plumbers/mcp/server"
require_relative "stimulus_plumbers/mcp/cli"
