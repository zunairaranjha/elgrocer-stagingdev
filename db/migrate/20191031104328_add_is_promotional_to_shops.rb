class AddIsPromotionalToShops < ActiveRecord::Migration
  def change
    add_column :shops, :is_promotional, :boolean, default: false
  end
end
