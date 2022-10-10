class CreateShopperCartProducts < ActiveRecord::Migration
  def change
    create_table :shopper_cart_products do |t|
      t.integer :shopper_id
      t.integer :retailer_id
      t.integer :product_id
      t.integer :quantity

      t.timestamps null: false
    end
  end
end
