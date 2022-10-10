class CreatRecipesCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :recipes_categories, id: false do |t|
      t.integer :recipe_id
      t.integer :recipe_category_id
    end
  end
end
