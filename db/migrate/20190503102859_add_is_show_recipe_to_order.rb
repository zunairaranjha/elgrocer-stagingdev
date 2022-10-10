class AddIsShowRecipeToOrder < ActiveRecord::Migration
  def change
  	add_column :retailers, :is_show_recipe, :bool, default: false
  end
end
