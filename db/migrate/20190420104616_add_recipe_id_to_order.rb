class AddRecipeIdToOrder < ActiveRecord::Migration
  def change
  	add_column :orders, :recipe_id, :integer
  end
end
