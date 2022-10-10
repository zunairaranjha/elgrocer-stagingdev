class AddPromotionOnlyIsActiveToShop < ActiveRecord::Migration[5.1]
  def change
    add_column :shops, :promotion_only, :boolean, :default => false
    add_column :shop_promotions, :is_active, :boolean, :default => true
  end
end
