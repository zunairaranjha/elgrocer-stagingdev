class AddRetalierNameToALocationWithoutShops < ActiveRecord::Migration
  def change
    add_column :a_location_without_shops, :store_name, :string
  end
end
