class AddIsAvailableToShop < ActiveRecord::Migration
  def change
    add_column :shops, :is_available, :boolean, default: true
  end
end
