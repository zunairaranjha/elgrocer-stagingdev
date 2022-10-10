class DropConOnCategories < ActiveRecord::Migration
  def change
    change_column :categories, :lft, :integer, :null => true
    change_column :categories, :rgt, :integer, :null => true
  end
end
