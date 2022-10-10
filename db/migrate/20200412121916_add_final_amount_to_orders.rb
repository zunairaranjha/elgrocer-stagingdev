class AddFinalAmountToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :final_amount, :float
  end
end
