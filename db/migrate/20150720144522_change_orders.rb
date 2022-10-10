class ChangeOrders < ActiveRecord::Migration
  def up
    rename_column :orders, :retailer_phone_contact_email, :retailer_contact_email
    remove_column :orders, :retailer_delivery_range
    add_column :orders, :retailer_delivery_range, :integer
  end

  def down
    rename_column :orders, :retailer_contact_email, :retailer_phone_contact_email
    remove_column :orders, :retailer_delivery_range
    add_column :orders, :retailer_delivery_range, :string
  end
end
