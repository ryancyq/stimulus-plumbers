# frozen_string_literal: true

require_relative "helpers/plumber_helper"
require_relative "helpers/icon_helper"
require_relative "helpers/list_helper"
require_relative "helpers/ordered_list_helper"
require_relative "helpers/avatar_helper"
require_relative "helpers/button_helper"
require_relative "helpers/calendar_helper"
require_relative "helpers/calendar_turbo_helper"
require_relative "helpers/card_helper"
require_relative "helpers/combobox_helper"
require_relative "helpers/divider_helper"
require_relative "helpers/link_helper"
require_relative "helpers/popover_helper"
require_relative "helpers/progress_helper"
require_relative "helpers/timeline_helper"

module StimulusPlumbers
  module Helpers
    include PlumberHelper
    include IconHelper
    include ListHelper
    include OrderedListHelper
    include AvatarHelper
    include ButtonHelper
    include CalendarHelper
    include CalendarTurboHelper
    include CardHelper
    include ComboboxHelper
    include DividerHelper
    include LinkHelper
    include PopoverHelper
    include ProgressHelper
    include TimelineHelper
  end
end
