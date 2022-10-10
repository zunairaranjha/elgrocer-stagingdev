class AddReceiptNoToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :receipt_no, :string
  end
end
