# frozen_string_literal: true

class SignIn
  include ActiveModel::Model

  attr_accessor :email, :password, :remember_me
end
