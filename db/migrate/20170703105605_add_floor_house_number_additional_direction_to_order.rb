class AddFloorHouseNumberAdditionalDirectionToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :shopper_address_floor, :string
    add_column :orders, :shopper_address_additional_direction, :string
    add_column :orders, :shopper_address_house_number, :string
  end
end
