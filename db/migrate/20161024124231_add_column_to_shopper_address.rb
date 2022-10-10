class AddColumnToShopperAddress < ActiveRecord::Migration
  def change
    add_column :shopper_addresses, :street_address, :string
    add_column :shopper_addresses, :street_number, :string
    add_column :shopper_addresses, :route, :string
    add_column :shopper_addresses, :intersection, :string
    add_column :shopper_addresses, :political, :string
    add_column :shopper_addresses, :country, :string
    add_column :shopper_addresses, :administrative_area_level_1, :string
    add_column :shopper_addresses, :locality, :string
    add_column :shopper_addresses, :ward, :string
    add_column :shopper_addresses, :sublocality, :string
    add_column :shopper_addresses, :neighborhood, :string
    add_column :shopper_addresses, :premise, :string
    add_column :shopper_addresses, :subpremise, :string
    add_column :shopper_addresses, :postal_code, :integer
    add_column :shopper_addresses, :natural_feature, :string
    add_column :shopper_addresses, :airport, :string
    add_column :shopper_addresses, :park, :string
  end
end