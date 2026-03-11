# frozen_string_literal: true

class SignUp
  include ActiveModel::Model

  attr_accessor :name,
                :email,
                :password,
                :bio,
                :age,
                :birth_date,
                :newsletter,
                :gender,
                :country

  def self.model_name
    ActiveModel::Name.new(self, nil, "SignUp")
  end
end
