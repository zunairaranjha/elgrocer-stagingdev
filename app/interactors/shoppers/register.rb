class Shoppers::Register < Shoppers::Base

  string :email
  string :name, default: nil
  string :phone_number, default: ''
  string :password
  string :password_confirmation, default: nil
  string :registration_id, default: nil
  integer :device_type, default: nil
  string :referrer_code, default: nil
  string :language, default: 'en'

  validate :shopper_is_new
  #validate :password_is_correct
  validate :referrer_exist

  def execute
    create_shopper!
  end

  private

  def new_params
    params = {
      email: email.downcase,
      name: name,
      phone_number: phone_number,
      password: password,
      password_confirmation: password,
      language: language
    }
    params.merge({registration_id: registration_id, device_type: device_type}) if registration_id and device_type
    params.merge!({referred_by: Shopper.find_by(referral_code: referrer_code.downcase).id}) unless referrer_code.blank?
    params
  end

  def create_shopper!
    shopper = Shopper.create!(new_params)
    shopper.save_push_token!(registration_id, device_type)
    shopper.save_referral_wallet(1)
    # shopper.welcome_notify
    shopper
  end

  private

  def shopper_is_new
    errors.add(:email, 'Shopper does exist') if Shopper.exists?(:email => email.downcase)
    errors.add(:phone, 'Shopper does exist') if phone_number.phony_normalized and Shopper.exists?(:phone_number => phone_number)
  end

  def referrer_exist
    errors.add(:referrer_code, 'Invalid referrer code') if referrer_code && !Shopper.exists?(:referral_code => referrer_code.downcase)
  end
end
