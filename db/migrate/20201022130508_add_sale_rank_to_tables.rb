class AddSaleRankToTables < ActiveRecord::Migration
  def change
    add_column :categories, :sale_rank, :integer, :default => 0
    add_column :products, :sale_rank, :integer, :default => 0
  end
end
