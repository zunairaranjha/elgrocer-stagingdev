class AddExecutedToOrders < ActiveRecord::Migration
    # I had to change it to status_id.
  def up
    add_column :orders, :status_id, :integer, default: 0
  end
  def down
    drop_column :orders, :status_id
  end
end
