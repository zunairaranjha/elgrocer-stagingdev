class AddHardwareIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :hardware_id, :string
  end
end
