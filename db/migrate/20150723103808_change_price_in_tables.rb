class ChangePriceInTables < ActiveRecord::Migration
  def up
    add_column :shops, :price_dollars, :integer
    add_column :orders, :total_value, :float
  end
  def down
    remove_column :shops, :price_dollars, :integer
    remove_column :orders, :total_value, :float
  end
end
