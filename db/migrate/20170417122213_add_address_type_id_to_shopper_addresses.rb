class AddAddressTypeIdToShopperAddresses < ActiveRecord::Migration
  def change
    add_column :shopper_addresses, :address_type_id, :integer, default: 1
  end
end
