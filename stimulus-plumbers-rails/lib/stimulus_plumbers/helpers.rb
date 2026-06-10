# frozen_string_literal: true

require_relative "helpers/plumber_helper"
require_relative "helpers/list_helper"
require_relative "helpers/avatar_helper"
require_relative "helpers/button_helper"
require_relative "helpers/calendar_helper"
require_relative "helpers/calendar_turbo_helper"
require_relative "helpers/card_helper"
require_relative "helpers/combobox_helper"
require_relative "helpers/divider_helper"
require_relative "helpers/link_helper"
require_relative "helpers/popover_helper"

module StimulusPlumbers
  module Helpers
    include PlumberHelper
    include ListHelper
    include AvatarHelper
    include ButtonHelper
    include CalendarHelper
    include CalendarTurboHelper
    include CardHelper
    include ComboboxHelper
    include DividerHelper
    include LinkHelper
    include PopoverHelper
  end
end
