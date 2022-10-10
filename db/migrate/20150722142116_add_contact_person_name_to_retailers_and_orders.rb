class AddContactPersonNameToRetailersAndOrders < ActiveRecord::Migration
  def up
    add_column :retailers, :contact_person_name, :string
    add_column :orders, :retailer_contact_person_name, :string
  end

  def down
    remove_column :retailers, :contact_person_name
    remove_column :orders, :retailer_contact_person_name
  end
end
