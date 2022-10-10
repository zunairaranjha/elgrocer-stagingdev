class AddColumnsToShopperAddress < ActiveRecord::Migration
  def change
    add_column :shopper_addresses, :floor, :string
    add_column :shopper_addresses, :additional_direction, :string
    add_column :shopper_addresses, :house_number, :string
  end
end
