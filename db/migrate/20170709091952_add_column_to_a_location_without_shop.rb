class AddColumnToALocationWithoutShop < ActiveRecord::Migration
  def change
    add_column :a_location_without_shops, :street_address, :string
    add_column :a_location_without_shops, :street_number, :string
    add_column :a_location_without_shops, :route, :string
    add_column :a_location_without_shops, :intersection, :string
    add_column :a_location_without_shops, :political, :string
    add_column :a_location_without_shops, :country, :string
    add_column :a_location_without_shops, :administrative_area_level_1, :string
    add_column :a_location_without_shops, :locality, :string
    add_column :a_location_without_shops, :ward, :string
    add_column :a_location_without_shops, :sublocality, :string
    add_column :a_location_without_shops, :neighborhood, :string
    add_column :a_location_without_shops, :premise, :string
    add_column :a_location_without_shops, :subpremise, :string
    add_column :a_location_without_shops, :postal_code, :integer
    add_column :a_location_without_shops, :natural_feature, :string
    add_column :a_location_without_shops, :airport, :string
    add_column :a_location_without_shops, :park, :string
  end
end
