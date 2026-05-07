# frozen_string_literal: true

require_relative "helpers/plumber_helper"
require_relative "helpers/action_list_helper"
require_relative "helpers/avatar_helper"
require_relative "helpers/button_helper"
require_relative "helpers/calendar_helper"
require_relative "helpers/calendar_turbo_helper"
require_relative "helpers/card_helper"
require_relative "helpers/combobox_helper"
require_relative "helpers/popover_helper"

module StimulusPlumbers
  module Helpers
    include PlumberHelper
    include ActionListHelper
    include AvatarHelper
    include ButtonHelper
    include CalendarHelper
    include CalendarTurboHelper
    include CardHelper
    include ComboboxHelper
    include PopoverHelper
  end
end
