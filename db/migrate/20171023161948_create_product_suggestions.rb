class CreateProductSuggestions < ActiveRecord::Migration
  def change
    create_table :product_suggestions do |t|
      t.string :name
      t.integer :shopper_id
      t.integer :retailer_id

      t.timestamps null: false
    end
  end
end
