class Shoppers::Base < ActiveInteraction::Base

  private

  def shopper_exists
    errors.add(:shopper_id, 'Shopper does not exist') unless shopper.present?
  end

  def password_is_correct
    errors.add(:password, 'Password and password confirmation are different!') if password!=password_confirmation
  end
end
