class AddDeliveryRiderToRetailerDeliveryZone < ActiveRecord::Migration
  def change
    add_column :retailer_delivery_zones, :delivery_fee, :float, default: 0
    add_column :retailer_delivery_zones, :rider_fee, :float, default: 0
  end
end
