class AddDeepLinkToRecipe < ActiveRecord::Migration
  def change
  	add_column :recipes, :deep_link, :string
  end
end
