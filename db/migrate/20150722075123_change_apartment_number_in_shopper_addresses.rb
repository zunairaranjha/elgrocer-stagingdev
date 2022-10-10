class ChangeApartmentNumberInShopperAddresses < ActiveRecord::Migration
  def up
    change_column :shopper_addresses, :apartment_number, :string
    change_column :orders, :shopper_address_apartment_number, :string
  end

  def down
    change_column :shopper_addresses, :apartment_number, :integer
    change_column :orders, :shopper_address_apartment_number, :integer
  end
end
