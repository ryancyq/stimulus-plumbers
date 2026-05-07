# frozen_string_literal: true

require "active_model"

class FormBuilderModel
  include ActiveModel::Model

  attr_accessor :email, :password, :remember_me, :role, :birthday, :country, :city, :meeting_time

  def self.model_name
    ActiveModel::Name.new(self, nil, "sign_in_form")
  end
end
