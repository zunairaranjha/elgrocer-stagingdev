class CreateOrderSubstitutions < ActiveRecord::Migration
  def change
    create_table :order_substitutions do |t|
      t.integer :order_id
      t.integer :product_id
      t.integer :substituting_product_id
      t.integer :shopper_id
      t.integer :retailer_id
      t.boolean :is_selected

      t.timestamps null: false
    end
  end
end
