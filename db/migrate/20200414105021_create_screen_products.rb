class CreateScreenProducts < ActiveRecord::Migration
  def change
    create_table :screen_products do |t|
      t.integer :screen_id
      t.integer :product_id
      t.integer :priority
    end
  end
end
