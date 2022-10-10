class AddMessageToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :message, :string
  end
  def down
    remove_column :orders, :message
  end
end
