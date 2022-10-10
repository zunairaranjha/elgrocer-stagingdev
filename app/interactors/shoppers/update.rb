class Shoppers::Update < Shoppers::Base

  integer :shopper_id
  string :email, default: nil
  string :name, default: nil
  string :phone_number, default: nil
  string :password, default: nil
  string :password_confirmation, default: nil
  string :language, default: nil

  validate :shopper_exists
  # validate :password_is_correct

  def execute
    update_shopper!
  end

  private

  def shopper
    @shopper ||= Shopper.find(shopper_id)
  end

  def update_params
    params = {
      email: email,
      name: shopper_name,
      password: password,
      password_confirmation: password_confirmation,
      language: language
    }
    params.compact
  end

  def update_shopper!
    shopper_address_update
    shopper.update!(update_params)

    shopper
  end

  def shopper_name
    shopper.name.blank? ? name : shopper.name
  end

  def shopper_address_update
    shopper_address = shopper.shopper_addresses.find_by(default_address: true)
    if shopper_address
      shopper_address.update(shopper_name: name, phone_number: phone_number)
    else

    end
  end

  private


end
