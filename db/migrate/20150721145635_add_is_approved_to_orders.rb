class AddIsApprovedToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :is_approved, :boolean, default: false, null: false
  end
  def down
    remove_column :orders, :is_approved
  end
end
