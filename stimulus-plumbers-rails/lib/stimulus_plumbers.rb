# frozen_string_literal: true

require_relative "stimulus_plumbers/version"

require "active_support"
require "active_support/core_ext/string"
require "view_component"

require_relative "stimulus_plumbers/configuration"
require_relative "stimulus_plumbers/components/action_list/renderer"
require_relative "stimulus_plumbers/components/avatar/renderer"
require_relative "stimulus_plumbers/components/button/renderer"
require_relative "stimulus_plumbers/components/card/renderer"
require_relative "stimulus_plumbers/components/date_picker/renderer"
require_relative "stimulus_plumbers/components/popover/renderer"
require_relative "stimulus_plumbers/form/field_component"
require_relative "stimulus_plumbers/form/builder"
require_relative "stimulus_plumbers/helpers"
require_relative "stimulus_plumbers/logger"

module StimulusPlumbers
  class << self
    def configure
      yield config
    end

    def config
      @config ||= Configuration.new
    end
  end
end

require "stimulus_plumbers/engine" if defined?(Rails::Engine)

HELPERS = %w[
  stimulus_plumbers/components/plumber/attributes
  stimulus_plumbers/components/plumber/stimulus_registry
  stimulus_plumbers/components/plumber/views
  stimulus_plumbers/components/plumber/base
].freeze

BASES = %w[
  stimulus_plumbers/components/container_component
  stimulus_plumbers/components/divider_component
].freeze

PRELOAD = (HELPERS + BASES).freeze

PRELOAD.each do |path|
  require_relative path
end

Dir[File.join(__dir__, "stimulus_plumbers", "components", "**", "*_component.rb")].sort.each do |file|
  next if PRELOAD.any? { |preloaded| file.chomp(".rb").end_with?(preloaded) }

  require file
end
