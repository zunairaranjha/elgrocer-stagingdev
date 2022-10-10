class AddFlagsToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :shopper_deleted, :boolean, default: false
    add_column :orders, :retailer_deleted, :boolean, default: false
  end

  def down
    remove_column :orders, :shopper_deleted
    remove_column :orders, :retailer_deleted
  end
end
