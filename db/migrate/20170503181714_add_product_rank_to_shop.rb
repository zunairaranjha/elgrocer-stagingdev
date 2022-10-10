class AddProductRankToShop < ActiveRecord::Migration
  def change
    add_column :shops, :product_rank, :decimal, default: 0
  end
end
