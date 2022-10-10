class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :barcode
      t.integer :product_brand_id
      t.integer :product_category_id
      t.timestamps null: false
    end
  end
end
