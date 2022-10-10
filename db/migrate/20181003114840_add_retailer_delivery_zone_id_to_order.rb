class AddRetailerDeliveryZoneIdToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :retailer_delivery_zone_id, :integer
  end
end
