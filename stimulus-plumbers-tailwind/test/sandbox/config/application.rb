# frozen_string_literal: true

require_relative "boot"

require "active_support/version"
require "logger" if ActiveSupport.version < "7.0"

require "action_controller"
require "action_view"
require "active_model"
require "active_support/core_ext"
require "rails"
require "sprockets/railtie" if Rails.version < "7.0"
require "stimulus_plumbers_tailwind"

class TestApp < Rails::Application
  rails_version = Rails.gem_version.segments.first(2).join(".")
  config.load_defaults rails_version

  config.secret_key_base = "test_secret_key_base"
  config.hosts.clear
  config.root = File.expand_path("..", __dir__)

  # One sandbox app for every suite: the core gem's sandbox owns the controllers, models, routes,
  # and views. This sandbox adds its own layout (Tailwind CSS) ahead of the core views.
  core_sandbox = File.expand_path("../../../../stimulus-plumbers-rails/test/sandbox", __dir__)
  %w[app/controllers app/models app/views].each do |path|
    config.paths[path] << File.join(core_sandbox, path)
  end
  config.paths["config/routes.rb"] = File.join(core_sandbox, "config/routes.rb")
  config.paths["config/routes"] = File.join(core_sandbox, "config/routes")

  config.middleware.use Rack::Static,
                        urls: ["/dist", "/node_modules"],
                        root: File.expand_path("../../../../stimulus-plumbers", __dir__)

  config.middleware.use Rack::Static,
                        urls: ["/tailwind.css"],
                        root: File.expand_path("../public", __dir__)
end
