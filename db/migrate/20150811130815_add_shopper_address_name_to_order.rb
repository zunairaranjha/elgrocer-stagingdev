class AddShopperAddressNameToOrder < ActiveRecord::Migration
  def up
    add_column :orders, :shopper_address_name, :string
  end

  def down
    remove_column :orders, :shopper_address_name
  end
end
