# frozen_string_literal: true

scope "/popover", controller: "components" do
  get :combobox
  get :search
  get :turbo, action: "popover_turbo"
  get :frame, action: "popover_frame"
  get :frame_replacement, action: "popover_frame_replacement"
  get "", action: "popover"
end
