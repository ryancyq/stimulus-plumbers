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
require_relative "stimulus_plumbers/plumber/slots"
require_relative "stimulus_plumbers/plumber/base"

# -- UI components --
require_relative "stimulus_plumbers/components/icon"
require_relative "stimulus_plumbers/components/indicator"
require_relative "stimulus_plumbers/components/avatar"
require_relative "stimulus_plumbers/components/button"
require_relative "stimulus_plumbers/components/button/slots"
require_relative "stimulus_plumbers/components/button/group"
require_relative "stimulus_plumbers/components/link"
require_relative "stimulus_plumbers/components/link/slots"
require_relative "stimulus_plumbers/components/card"
require_relative "stimulus_plumbers/components/card/slots"
require_relative "stimulus_plumbers/components/list"
require_relative "stimulus_plumbers/components/list/section"
require_relative "stimulus_plumbers/components/list/item"
require_relative "stimulus_plumbers/components/list/item/slots"
require_relative "stimulus_plumbers/components/ordered_list"
require_relative "stimulus_plumbers/components/ordered_list/item"
require_relative "stimulus_plumbers/components/ordered_list/item/slots"
require_relative "stimulus_plumbers/components/timeline"
require_relative "stimulus_plumbers/components/timeline/event"
require_relative "stimulus_plumbers/components/timeline/event/slots"
require_relative "stimulus_plumbers/components/timeline/group"
require_relative "stimulus_plumbers/components/divider"
require_relative "stimulus_plumbers/components/input_group"
require_relative "stimulus_plumbers/components/popover"
require_relative "stimulus_plumbers/components/popover/trigger"
require_relative "stimulus_plumbers/components/popover/panel"
require_relative "stimulus_plumbers/components/progress_bar"
require_relative "stimulus_plumbers/components/progress_ring"
require_relative "stimulus_plumbers/components/progress_meter"

# -- Calendar --
require_relative "stimulus_plumbers/components/calendar"
require_relative "stimulus_plumbers/components/calendar/turbo"
require_relative "stimulus_plumbers/components/calendar/turbo/days_of_week"
require_relative "stimulus_plumbers/components/calendar/turbo/days_of_month"
require_relative "stimulus_plumbers/components/calendar/turbo/months_of_year"
require_relative "stimulus_plumbers/components/calendar/turbo/years_of_decade"

# -- Combobox --
require_relative "stimulus_plumbers/components/combobox"
require_relative "stimulus_plumbers/components/combobox/trigger"
require_relative "stimulus_plumbers/components/combobox/options"
require_relative "stimulus_plumbers/components/combobox/options/option"
require_relative "stimulus_plumbers/components/combobox/options/option_group"
require_relative "stimulus_plumbers/components/combobox/date"
require_relative "stimulus_plumbers/components/combobox/date/navigator"
require_relative "stimulus_plumbers/components/combobox/date/navigation"
require_relative "stimulus_plumbers/components/combobox/dropdown"
require_relative "stimulus_plumbers/components/combobox/typeahead"
require_relative "stimulus_plumbers/components/combobox/time"
require_relative "stimulus_plumbers/components/combobox/builder"

# -- Form --
require_relative "stimulus_plumbers/form/field"
require_relative "stimulus_plumbers/form/fields/error"
require_relative "stimulus_plumbers/form/fields/group"
require_relative "stimulus_plumbers/form/fields/hint"
require_relative "stimulus_plumbers/form/fields/label"
require_relative "stimulus_plumbers/form/fields/label/floating"
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
