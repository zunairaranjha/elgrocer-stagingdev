class AddSeoAndMessageColumns < ActiveRecord::Migration
  def change
    add_column :categories, :message, :string
    add_column :categories, :message_ar, :string
    add_column :categories, :seo_data, :string
    add_column :brands, :seo_data, :string
    add_column :retailers, :seo_data, :string
    add_column :recipes, :seo_data, :string
    add_column :recipe_categories, :seo_data, :string
    add_column :chefs, :seo_data, :string
    add_column :locations, :seo_data, :string
  end
end
