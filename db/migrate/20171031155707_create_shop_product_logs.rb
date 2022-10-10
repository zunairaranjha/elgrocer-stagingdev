class CreateShopProductLogs < ActiveRecord::Migration
  def change
    create_table :shop_product_logs do |t|
      t.integer :order_id
      t.integer :retailer_id
      t.integer :product_id
      t.integer :category_id
      t.integer :subcategory_id
      t.integer :brand_id
      t.string  :retailer_name
      t.string  :product_name
      t.string  :category_name
      t.string  :brand_name
      t.string  :subcategory_name
      t.boolean  :is_published
      t.boolean  :is_available
      t.references :owner, polymorphic: true


      t.timestamps
    end
  end
end
