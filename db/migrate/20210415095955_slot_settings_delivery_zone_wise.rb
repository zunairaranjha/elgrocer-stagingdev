class SlotSettingsDeliveryZoneWise < ActiveRecord::Migration[5.1]
  def change
    add_column :retailer_delivery_zones, :delivery_slot_skip_time, :integer, default: 0
    add_column :retailer_delivery_zones, :cutoff_time, :integer, default: 0
    add_column :retailer_delivery_zones, :delivery_type, :integer
    add_column :retailer_has_services, :delivery_type, :integer
  end
end
