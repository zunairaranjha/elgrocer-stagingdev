class CreateShopPromotions < ActiveRecord::Migration[5.1]
  def change
    create_table :shop_promotions do |t|
      t.integer :product_id, null: false
      t.integer :retailer_id, null: false
      t.float :price, default: 0.0
      t.float :standard_price, default:0
      t.integer :product_limit, default: 0
      t.float :start_time
      t.float :end_time
      t.timestamps null: false
      t.string :price_currency, default: "AED", null: false
    end
    add_column :shopper_cart_products, :shop_promotion_id, :integer
    add_column :shopper_cart_products, :delivery_time, :float
    add_column :order_substitutions, :shop_promotion_id, :integer
    add_column :order_positions, :promotional_price, :float, default: 0.0
  end
end
