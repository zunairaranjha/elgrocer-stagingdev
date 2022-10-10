class AddColumnsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :delivery_type_id, :integer
    add_column :orders, :delivery_slot_id, :integer
  end
end
