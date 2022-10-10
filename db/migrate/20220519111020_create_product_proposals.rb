class CreateProductProposals < ActiveRecord::Migration[5.1]
  def change
    create_table :product_proposals do |t|
      t.string :barcode
      t.string :name
      t.string :slug
      t.integer :order_id
      t.integer :product_id
      t.integer :oos_product_id
      t.integer :brand_id
      t.string :price_currency, default: 'AED'
      t.integer :retailer_id
      t.boolean :is_promotion_available, default: false
      t.integer :type_id
      t.integer :status_id
      t.float :price
      t.float :promotional_price
      t.string :size_unit
      t.jsonb :details, default: {}

      t.timestamps
    end
  end
end
