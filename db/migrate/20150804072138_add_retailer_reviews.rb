class AddRetailerReviews < ActiveRecord::Migration
  def change
    create_table(:retailer_reviews) do |t|
      t.integer :retailer_id, :null => true, :index => true
      t.float :overall_rating
      t.float :delivery_speed_rating
      t.float :order_accuracy_rating
      t.float :quality_rating
      t.float :price_rating

      t.timestamps
    end
  end
end
