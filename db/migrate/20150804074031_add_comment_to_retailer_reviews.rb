class AddCommentToRetailerReviews < ActiveRecord::Migration
  def change
    add_column :retailer_reviews, :comment, :text
  end
end
