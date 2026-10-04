# frozen_string_literal: true

get "/modal", controller: "components", action: "modal"
get "/modal/turbo", controller: "components", action: "modal_turbo"
get "/modal/form", controller: "components", action: "modal_form"
post "/modal/form/submit", controller: "components", action: "modal_form_submit"
