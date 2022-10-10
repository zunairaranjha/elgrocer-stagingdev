class AddContactInfoToShopperAddresses < ActiveRecord::Migration
  def change
    add_column :shopper_addresses, :phone_number, :string
    add_column :shopper_addresses, :shopper_name, :string
  end
end
