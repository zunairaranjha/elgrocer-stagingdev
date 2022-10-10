class AddCategoryIdsToOrderPosition < ActiveRecord::Migration
  def change
    add_column :order_positions, :category_id, :integer
    add_column :order_positions, :subcategory_id, :integer
    add_column :order_positions, :brand_id, :integer
  end
end
