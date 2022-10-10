class AddSlugToRecipeSection < ActiveRecord::Migration
  def change
    add_column :recipes, :slug, :string
    add_column :recipe_categories, :slug, :string
    add_column :chefs, :slug,:string
  end
end
