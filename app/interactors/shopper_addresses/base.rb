class ShopperAddresses::Base < ActiveInteraction::Base

  private

  def shopper_exists
    errors.add(:shopper_id, 'Shopper does not exist') unless Shopper.exists?(id: shopper_id)
  end

  def shopper_address_exists
    errors.add(:shopper_address, 'Shopper Address do not exist') unless ShopperAddress.exists?(id: address_id, shopper_id: shopper_id)
  end

  def shopper_address_default
    errors.add(:default_address, 'Cannot delete default address') unless default_address
  end
end
