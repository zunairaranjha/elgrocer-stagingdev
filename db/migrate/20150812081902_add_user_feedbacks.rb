class AddUserFeedbacks < ActiveRecord::Migration
  def up
    create_table :retailer_feedbacks do |t|
      t.integer :retailer_id, index: true, null: false
      t.string :content
      t.timestamps
    end

    create_table :shopper_feedbacks do |t|
      t.integer :shopper_id, index: true, null: false
      t.string :content
      t.timestamps
    end
  end

  def down
    drop_table :retailer_feedbacks
    drop_table :shopper_feedbacks
  end
end
