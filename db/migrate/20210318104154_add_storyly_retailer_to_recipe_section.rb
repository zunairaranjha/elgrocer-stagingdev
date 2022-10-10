class AddStorylyRetailerToRecipeSection < ActiveRecord::Migration[5.1]
  def change
    add_column :recipes, :storyly_slug, :string
    add_column :chefs, :storyly_slug, :string
    add_column :recipes, :priority, :integer
    add_column :chefs, :priority, :integer
    add_column :recipes, :retailer_ids, :integer, array: true, :default => '{}'
    add_column :recipes, :exclude_retailer_ids, :integer, array: true, :default => '{}'
    add_column :recipes, :retailer_group_ids, :integer, array: true, :default => '{}'
    add_column :recipes, :store_type_ids, :integer, array: true, :default => '{}'
    add_column :recipes, :translations, :jsonb, default: {}
    add_column :chefs, :translations, :jsonb, default: {}
    add_column :recipe_categories, :translations, :jsonb, default: {}
    add_column :cooking_steps, :translations, :jsonb, default: {}
    add_column :ingredients, :translations, :jsonb, default: {}
  end
end
