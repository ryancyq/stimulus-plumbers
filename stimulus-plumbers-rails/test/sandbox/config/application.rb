# frozen_string_literal: true

require_relative "boot"

require "logger" if RUBY_VERSION >= "2.7" # for rails < 7.0
require "rails"
require "action_controller"
require "action_view"
require "active_model"
require "active_support/core_ext"
require "view_component"

# Minimal test application for component testing
class TestApp < Rails::Application
  # Load defaults for the current Rails version
  rails_version = Rails.gem_version.segments.first(2).join(".")
  config.load_defaults rails_version

  # Application-level configuration
  config.secret_key_base = "test_secret_key_base"
  config.hosts.clear
  config.root = File.expand_path("..", __dir__)

  # Serve compiled Stimulus controllers from the npm package dist directory.
  # Rack::Static prepends root to the full request path, so root must be the
  # npm package directory and the URL prefix must be "/dist".
  config.middleware.use Rack::Static,
    urls: ["/dist"],
    root: File.expand_path("../../../../stimulus-plumbers", __dir__)

  # ViewComponent previews
  config.view_component.preview_paths << Rails.root.join("previews")
  config.view_component.show_previews = true
  config.view_component.default_preview_layout = "preview"
end
