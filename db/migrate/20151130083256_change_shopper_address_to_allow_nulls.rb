class ChangeShopperAddressToAllowNulls < ActiveRecord::Migration
  def change
    change_column_null :shopper_addresses, :address_name, true
  end
end
