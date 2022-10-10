class AddMinBasketValueToRetailerDeliveryZones < ActiveRecord::Migration
  def change
    add_column :retailer_delivery_zones, :min_basket_value, :decimal, default: 0
  end
end
