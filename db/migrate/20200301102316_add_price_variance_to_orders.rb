class AddPriceVarianceToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :price_variance, :float, :default => 0.0
  end
end
