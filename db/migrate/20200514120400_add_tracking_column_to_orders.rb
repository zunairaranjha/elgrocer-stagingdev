class AddTrackingColumnToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :picker_id, :integer
    add_column :orders, :checkout_person_id, :integer
    add_column :orders, :delivery_person_id, :integer
    add_column :orders, :delivery_method, :integer
    add_column :orders, :delivery_vehicle, :integer

  end
end
