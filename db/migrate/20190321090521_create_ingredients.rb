class CreateIngredients < ActiveRecord::Migration
  def change
    create_table :ingredients do |t|
      t.integer :product_id
      t.float :qty
      t.string :qty_unit
      t.integer :recipe_id

      t.timestamps
    end
  end
end
