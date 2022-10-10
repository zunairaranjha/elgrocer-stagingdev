class CreateOrderFeedbacks < ActiveRecord::Migration
  def change
    create_table :order_feedbacks do |t|
      t.belongs_to :order, index: true
      t.integer :delivery
      t.integer :speed
      t.integer :accuracy
      t.integer :price
      t.string :comments

      t.timestamps null: false
    end
  end
end
