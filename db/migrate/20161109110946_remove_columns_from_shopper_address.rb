class RemoveColumnsFromShopperAddress < ActiveRecord::Migration
  def change
    remove_column :shopper_addresses, :park
    remove_column :shopper_addresses, :airport
    remove_column :shopper_addresses, :natural_feature
    remove_column :shopper_addresses, :postal_code
    remove_column :shopper_addresses, :subpremise
    remove_column :shopper_addresses, :ward
    remove_column :shopper_addresses, :political
    remove_column :shopper_addresses, :intersection
  end
end

