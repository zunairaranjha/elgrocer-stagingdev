class AddTraslationTablesToRetailer < ActiveRecord::Migration
  def change
    add_column :retailers,:company_name_ar,:string
    add_column :retailers,:company_address_ar,:string
  end
end
