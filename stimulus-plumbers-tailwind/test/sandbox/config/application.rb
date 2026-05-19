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

  config.middleware.use Rack::Static,
                        urls: ["/dist", "/node_modules"],
                        root: File.expand_path("../../../../stimulus-plumbers", __dir__)

  config.middleware.use Rack::Static,
                        urls: ["/tailwind.css"],
                        root: File.expand_path("../public", __dir__)
end
