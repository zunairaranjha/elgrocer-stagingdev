class AddShopperDataToOffer < ActiveRecord::Migration
  def up
    add_column :orders, :shopper_phone_number, :string
    add_column :orders, :shopper_name, :string

    add_column :orders, :shopper_address_id, :integer
    add_column :orders, :shopper_address_city, :string
    add_column :orders, :shopper_address_area, :string
    add_column :orders, :shopper_address_street, :string
    add_column :orders, :shopper_address_building_name, :string
    add_column :orders, :shopper_address_apartment_number, :integer
    add_column :orders, :shopper_address_floor_number, :integer
  end

  def down
    remove_column :orders, :shopper_phone_number, :string
    remove_column :orders, :shopper_name, :string

    remove_column :orders, :shopper_address_id, :integer
    remove_column :orders, :shopper_address_city, :string
    remove_column :orders, :shopper_address_area, :string
    remove_column :orders, :shopper_address_street, :string
    remove_column :orders, :shopper_address_building_name, :string
    remove_column :orders, :shopper_address_apartment_number, :integer
    remove_column :orders, :shopper_address_floor_number, :integer
  end
end
