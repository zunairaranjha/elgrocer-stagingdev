class AddDefaultAddressToShopperAddress < ActiveRecord::Migration
  def change
    add_column :shopper_addresses, :default_address, :bool, default: false
  end
end
