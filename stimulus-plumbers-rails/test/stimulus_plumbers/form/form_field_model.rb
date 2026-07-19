# frozen_string_literal: true

require "active_model"

class FormFieldModel
  include ActiveModel::Model

  attr_accessor :email, :password, :remember_me

  class << self
    def model_name
      ActiveModel::Name.new(self, nil, "sign_in_form")
    end
  end
end
