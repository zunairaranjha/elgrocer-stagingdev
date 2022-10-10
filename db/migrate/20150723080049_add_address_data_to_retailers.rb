class AddAddressDataToRetailers < ActiveRecord::Migration
  def up
    add_column :retailers, :street, :string
    add_column :retailers, :building, :string
    add_column :retailers, :apartment, :string
    add_column :retailers, :flat_number, :string
    add_column :retailers, :location_id, :integer

    add_column :orders, :retailer_street, :string
    add_column :orders, :retailer_building, :string
    add_column :orders, :retailer_apartment, :string
    add_column :orders, :retailer_flat_number, :string

    add_column :orders, :retailer_location_name, :string
    add_column :orders, :retailer_location_id, :integer

    add_column :orders, :shopper_address_location_name, :string
    add_column :orders, :shopper_address_location_id, :integer

    add_column :shopper_addresses, :location_id, :integer


  end

  def down
    remove_column :retailers, :street, :string
    remove_column :retailers, :building, :string
    remove_column :retailers, :apartment, :string
    remove_column :retailers, :flat_number, :string
    remove_column :retailers, :location_id, :integer


    remove_column :orders, :retailer_street, :string
    remove_column :orders, :retailer_building, :string
    remove_column :orders, :retailer_apartment, :string
    remove_column :orders, :retailer_flat_number, :string

    remove_column :orders, :retailer_location_name, :string
    remove_column :orders, :retailer_location_id, :integer

    remove_column :orders, :shopper_address_location_name, :string
    remove_column :orders, :shopper_address_location_id, :integer

    remove_column :shopper_addresses, :location_id, :integer

  end
end
