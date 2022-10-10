class CreateShops < ActiveRecord::Migration
  def change
    create_table :shops do |t|
      t.references :retailer, index: true
      t.references :product, index: true

      t.timestamps null: false
    end
    add_foreign_key :shops, :retailers
    add_foreign_key :shops, :products
  end
end
