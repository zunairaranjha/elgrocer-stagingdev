class Shoppers::RegisterSmiles < Shoppers::Base

  string :phone_number, default: ''

  validate :shopper_is_new

  def execute
    create_shopper!
  end

  private

  def new_params
    params = {
      phone_number: phone_number
    }
  end

  def create_shopper!
    shopper = Shopper.create!(new_params)
    #shopper.save_push_token!(registration_id, device_type)
    shopper.save_referral_wallet(1)
    # shopper.welcome_notify
    shopper
  end

  private

  def shopper_is_new
    errors.add(:phone, 'Shopper does exist') if phone_number.phony_normalized and Shopper.exists?(:phone_number => phone_number)
  end

  def referrer_exist
    errors.add(:referrer_code, 'Invalid referrer code') if referrer_code && !Shopper.exists?(:referral_code => referrer_code.downcase)
  end
end
