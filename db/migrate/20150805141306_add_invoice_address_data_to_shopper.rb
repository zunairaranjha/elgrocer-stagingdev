class AddInvoiceAddressDataToShopper < ActiveRecord::Migration

  def up
    add_column :shoppers, :invoice_city, :string
    add_column :shoppers, :invoice_street, :string
    add_column :shoppers, :invoice_building_name, :string
    add_column :shoppers, :invoice_apartment_number, :string
    add_column :shoppers, :invoice_floor_number, :integer
    add_column :shoppers, :invoice_location_id, :integer
  end

  def down
    remove_column :shoppers, :invoice_city, :string
    remove_column :shoppers, :invoice_street, :string
    remove_column :shoppers, :invoice_building_name, :string
    remove_column :shoppers, :invoice_apartment_number, :string
    remove_column :shoppers, :invoice_floor_number, :integer
    remove_column :shoppers, :invoice_location_id, :integer
  end

end
