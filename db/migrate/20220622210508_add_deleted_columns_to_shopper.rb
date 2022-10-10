class AddDeletedColumnsToShopper < ActiveRecord::Migration[5.1]
  def change
    add_column :shoppers, :is_deleted, :boolean, default: false
  end
end
