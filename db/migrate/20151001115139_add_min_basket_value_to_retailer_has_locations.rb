class AddMinBasketValueToRetailerHasLocations < ActiveRecord::Migration
  def up
    add_column :retailer_has_locations, :min_basket_value, :decimal, default: 0
  end
  def down
    remove_column :retailer_has_locations, :min_basket_value
  end
end
