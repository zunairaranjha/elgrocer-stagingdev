class ChangeFloatsToIntegersInRetailerReviews < ActiveRecord::Migration
  def up
    change_column :retailer_reviews, :overall_rating, :integer
    change_column :retailer_reviews, :delivery_speed_rating, :integer
    change_column :retailer_reviews, :order_accuracy_rating, :integer
    change_column :retailer_reviews, :quality_rating, :integer
    change_column :retailer_reviews, :price_rating, :integer
  end

  def down
    change_column :retailer_reviews, :overall_rating, :float
    change_column :retailer_reviews, :delivery_speed_rating, :float
    change_column :retailer_reviews, :order_accuracy_rating, :float
    change_column :retailer_reviews, :quality_rating, :float
    change_column :retailer_reviews, :price_rating, :float
  end
end
