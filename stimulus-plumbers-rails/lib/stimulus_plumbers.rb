# frozen_string_literal: true

require_relative "stimulus_plumbers/version"

require "active_support"
require "active_support/core_ext/string"

# -- Core infrastructure --
require_relative "stimulus_plumbers/configuration"
require_relative "stimulus_plumbers/helpers"
require_relative "stimulus_plumbers/logger"

# -- Plumber base --
require_relative "stimulus_plumbers/plumber/dispatcher"
require_relative "stimulus_plumbers/plumber/base"

# -- UI components --
require_relative "stimulus_plumbers/components/icon"
require_relative "stimulus_plumbers/components/avatar"
require_relative "stimulus_plumbers/components/button"
require_relative "stimulus_plumbers/components/button/group"
require_relative "stimulus_plumbers/components/card"
require_relative "stimulus_plumbers/components/card/section"
require_relative "stimulus_plumbers/components/action_list"
require_relative "stimulus_plumbers/components/action_list/section"
require_relative "stimulus_plumbers/components/action_list/item"
require_relative "stimulus_plumbers/components/divider"
require_relative "stimulus_plumbers/components/input_group"
require_relative "stimulus_plumbers/components/popover"
require_relative "stimulus_plumbers/components/popover/trigger"
require_relative "stimulus_plumbers/components/popover/panel"
require_relative "stimulus_plumbers/components/popover/builder"

# -- Calendar --
require_relative "stimulus_plumbers/components/calendar"
require_relative "stimulus_plumbers/components/calendar/month/turbo"
require_relative "stimulus_plumbers/components/calendar/month/turbo/days_of_week"
require_relative "stimulus_plumbers/components/calendar/month/turbo/days_of_month"

# -- Date picker --
require_relative "stimulus_plumbers/components/date_picker/navigator"
require_relative "stimulus_plumbers/components/date_picker/navigation"

# -- Combobox --
require_relative "stimulus_plumbers/components/combobox"
require_relative "stimulus_plumbers/components/combobox/variant"
require_relative "stimulus_plumbers/components/combobox/trigger"
require_relative "stimulus_plumbers/components/combobox/options"
require_relative "stimulus_plumbers/components/combobox/options/option"
require_relative "stimulus_plumbers/components/combobox/options/option_group"
require_relative "stimulus_plumbers/components/combobox/date"
require_relative "stimulus_plumbers/components/combobox/dropdown"
require_relative "stimulus_plumbers/components/combobox/typeahead"
require_relative "stimulus_plumbers/components/combobox/time"
require_relative "stimulus_plumbers/components/combobox/time/drum"

# -- Form --
require_relative "stimulus_plumbers/form/field"
require_relative "stimulus_plumbers/form/fields/error"
require_relative "stimulus_plumbers/form/fields/group"
require_relative "stimulus_plumbers/form/fields/hint"
require_relative "stimulus_plumbers/form/fields/label"
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
