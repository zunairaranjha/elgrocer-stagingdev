class AddLocationToScreens < ActiveRecord::Migration
  def change
    add_column :screens, :locations, :integer, array: true, :default => '{}'
    add_column :screens, :start_date, :datetime
    add_column :screens, :end_date, :datetime
    add_column :screens, :store_types, :integer, array: true, :default => '{}'
    add_column :screens, :retailer_groups, :integer, array: true, :default => '{}'
    add_column :screens, :retailer_ids, :integer, array: true, :default => '{}'
  end
end
