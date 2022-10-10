class AddPickupPriorityToCategories < ActiveRecord::Migration[5.1]
  def change
    add_column :categories, :pickup_priority, :integer, default: 0
  end
end
