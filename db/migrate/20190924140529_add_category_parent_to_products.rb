class AddCategoryParentToProducts < ActiveRecord::Migration
  def change
    add_column :products, :category_parent_id, :integer
  end
end
