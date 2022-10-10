class AddStockToShopsAndRetailers < ActiveRecord::Migration[5.1]
  def change
    add_column :shops, :stock_on_hand, :integer
    add_column :shops, :available_for_sale, :integer
    add_column :retailers, :with_stock_level, :boolean, default: false
  end
end
