class AddShopperIdToRetailerReviews < ActiveRecord::Migration
  def change
     add_column :retailer_reviews, :shopper_id, :integer, null: false, index: true
     # add_index :retailer_reviews, [:shopper_id]
  end
end
