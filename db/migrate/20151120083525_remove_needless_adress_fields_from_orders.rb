class RemoveNeedlessAdressFieldsFromOrders < ActiveRecord::Migration
  def change
  	remove_column :orders, :shopper_address_floor_number
  	remove_column :orders, :shopper_address_city
  end
end
