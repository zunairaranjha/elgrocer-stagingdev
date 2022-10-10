class AddTopSellingToSetting < ActiveRecord::Migration
  def change
    add_column :settings, :product_most_selling_days, :integer, default: 30
    add_column :settings, :product_trending_days, :integer, default: 7
  end
end
