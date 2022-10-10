class CreateRecipeCategories < ActiveRecord::Migration
  def change
    create_table :recipe_categories do |t|
      t.string :name
      t.integer :parent_id
      t.attachment :photo

      t.timestamps
    end
  end
end
