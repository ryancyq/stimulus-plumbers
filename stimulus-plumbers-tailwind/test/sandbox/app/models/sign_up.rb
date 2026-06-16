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
                :terms_of_service,
                :gender,
                :country,
                :role,
                :interests

  def self.model_name
    ActiveModel::Name.new(self, nil, "SignUp")
  end
end
