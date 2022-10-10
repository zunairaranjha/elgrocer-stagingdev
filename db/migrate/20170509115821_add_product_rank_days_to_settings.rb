class AddProductRankDaysToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :product_rank_days, :integer, default: 30
    add_column :settings, :product_rank_orders_limit, :integer, default: 10
    add_column :settings, :product_rank_date, :datetime
    add_column :settings, :product_derank_date, :datetime
  end
end
