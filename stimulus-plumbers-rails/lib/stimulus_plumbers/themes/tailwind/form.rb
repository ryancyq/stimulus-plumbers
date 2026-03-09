# frozen_string_literal: true

module StimulusPlumbers::Themes::Tailwind::Form
  INPUT_BASE    = %w[w-full rounded-md border px-3 py-2 text-sm text-gray-900 bg-white focus:outline-none focus:ring-2 focus:ring-offset-0].freeze
  INPUT_ERROR   = %w[border-red-700 focus:ring-red-700].freeze
  INPUT_DEFAULT = %w[border-gray-500 focus:ring-blue-700].freeze

  private

  def form_group_classes(layout: :stacked, state: :default)
    {
      classes: klasses(
        "flex", "gap-1", "mb-3",
        layout == :inline ? %w[flex-row items-center] : "flex-col"
      )
    }
  end

  def form_label_classes(required: false)
    { classes: klasses("text-sm", "font-medium", "text-gray-900") }
  end

  def form_required_mark_classes
    { classes: klasses("text-red-700", "ml-0.5") }
  end

  def form_details_classes
    { classes: klasses("text-xs", "text-gray-600") }
  end

  def form_error_classes
    { classes: klasses("text-xs", "text-red-700") }
  end

  def form_input_classes(state: :default)
    {
      classes: klasses(
        *INPUT_BASE,
        *(state == :error ? INPUT_ERROR : INPUT_DEFAULT)
      )
    }
  end

  def form_textarea_classes(state: :default)
    form_input_classes(state: state)
  end

  def form_file_classes(state: :default)
    form_input_classes(state: state)
  end

  def form_select_classes(state: :default)
    form_input_classes(state: state)
  end

  def form_checkbox_classes(state: :default)
    { classes: klasses("size-4", "rounded", "border-gray-500", "text-blue-700") }
  end

  def form_radio_classes(state: :default)
    { classes: klasses("size-4", "border-gray-500", "text-blue-700") }
  end

  def form_actor_classes(state: :default)
    {
      classes: klasses(
        "flex", "items-center", "overflow-hidden", "rounded-md", "border",
        state == :error ? "border-red-700" : "border-gray-500"
      )
    }
  end

  def form_input_reveal_classes
    { classes: klasses("flex-1", "border-0", "bg-transparent", "px-3", "py-2", "text-sm", "text-gray-900", "focus:outline-none") }
  end

  def form_reveal_button_classes
    { classes: klasses("self-stretch", "border-0", "bg-transparent", "px-3", "cursor-pointer", "text-gray-600", "hover:text-gray-900", "text-sm") }
  end
end
