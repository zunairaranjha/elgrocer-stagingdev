class AddLocationAddressToShopperAddresses < ActiveRecord::Migration
  def change
    add_column :shopper_addresses, :location_address, :string
  end
end
