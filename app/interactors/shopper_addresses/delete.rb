class ShopperAddresses::Delete < ShopperAddresses::Base
  integer :shopper_id
  integer :address_id

  validate :shopper_exists
  validate :shopper_address_exists

  def execute
    delete_shopper_addresses!
    nil
  end

  private

  def delete_shopper_addresses!
    ShopperAddress.find_by(shopper_id: shopper_id, id: address_id).destroy
  end

end
