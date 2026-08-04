# frozen_string_literal: true

class SignUp
  include ActiveModel::Model

  attr_accessor :name,
                :email,
                :password,
                :bio,
                :birth_date,
                :country,
                :newsletter,
                :resume

  class << self
    def model_name
      ActiveModel::Name.new(self, nil, "SignUp")
    end
  end
end
