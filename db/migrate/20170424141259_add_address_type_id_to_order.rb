class AddAddressTypeIdToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :shopper_address_type_id, :integer, default: 1
  end
end
