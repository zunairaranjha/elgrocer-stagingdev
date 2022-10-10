class CreateShopperRecipes < ActiveRecord::Migration[5.1]
  def change
    create_table :shopper_recipes do |t|
      t.integer :shopper_id
      t.integer :recipe_id
    end
  end
end
