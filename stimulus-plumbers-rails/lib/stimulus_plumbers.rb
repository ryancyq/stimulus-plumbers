# frozen_string_literal: true

require_relative "stimulus_plumbers/version"

require "active_support"
require "active_support/core_ext/string"

require_relative "stimulus_plumbers/configuration"
require_relative "stimulus_plumbers/helpers"
require_relative "stimulus_plumbers/logger"

require_relative "stimulus_plumbers/components/plumber/attributes"
require_relative "stimulus_plumbers/components/plumber/dispatcher"
require_relative "stimulus_plumbers/components/plumber/renderer"
require_relative "stimulus_plumbers/components/plumber/base"

require_relative "stimulus_plumbers/components/action_list/renderer"
require_relative "stimulus_plumbers/components/avatar/renderer"
require_relative "stimulus_plumbers/components/button/renderer"
require_relative "stimulus_plumbers/components/card/renderer"
require_relative "stimulus_plumbers/components/icon/renderer"
require_relative "stimulus_plumbers/components/calendar/days_of_month"
require_relative "stimulus_plumbers/components/calendar/days_of_week"
require_relative "stimulus_plumbers/components/calendar/navigator"
require_relative "stimulus_plumbers/components/calendar/renderer"
require_relative "stimulus_plumbers/components/date_picker/renderer"
require_relative "stimulus_plumbers/components/popover/renderer"
require_relative "stimulus_plumbers/form/field_component"
require_relative "stimulus_plumbers/form/builder"

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

require_relative "stimulus_plumbers/engine" if defined?(Rails::Engine)
