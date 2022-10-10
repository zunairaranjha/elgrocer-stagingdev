class AddDescriptionToChefAndRecipeCategory < ActiveRecord::Migration
  def change
    add_column :recipe_categories, :description, :string
    add_column :chefs, :description,:string
  end
end
