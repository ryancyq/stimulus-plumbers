# frozen_string_literal: true

class FormController < ApplicationController
  def sign_up
    @form = SignUp.new
  end

  def field_error
    @form = SignUp.new.tap do |f|
      f.errors.add(:email, "is already taken")
      f.errors.add(:name, "can't be blank")
      f.errors.add(:bio, "can't be blank")
      f.errors.add(:country, "is invalid")
      f.errors.add(:newsletter, "must be accepted")
      f.errors.add(:resume, "is required")
    end
  end

  def fieldset
    @form = Preferences.new.tap do |f|
      f.errors.add(:gender, "can't be blank")
      f.errors.add(:interests, "must select at least one")
    end
  end

  def choices
    @form = Preferences.new
  end

  def floating_label
    @form = SignUp.new.tap do |f|
      f.errors.add(:name, "can't be blank")
    end
  end

  def progress
    @form = Onboarding.new(completion: 45, profile_strength: 4)
  end

  def range
    @form = Preferences.new(volume: 45)
  end

  def code
    @form = Verification.new
  end

  def credit_card
    @form = Payment.new
  end

  def password
    @form = SignIn.new
  end
end
