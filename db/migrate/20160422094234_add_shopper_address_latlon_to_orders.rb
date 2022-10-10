class AddShopperAddressLatlonToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :shopper_address_latitude, :decimal, precision: 10, scale: 8
    add_column :orders, :shopper_address_longitude, :decimal, precision: 10, scale: 8
    add_column :orders, :shopper_address_location_address, :string
  end
end
