class DropFeedbacks < ActiveRecord::Migration
  def change
    drop_table :retailer_feedbacks
    drop_table :shopper_feedbacks
  end
end
