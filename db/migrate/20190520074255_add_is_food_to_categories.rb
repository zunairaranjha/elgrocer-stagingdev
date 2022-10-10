class AddIsFoodToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :is_food, :boolean
  end
end
