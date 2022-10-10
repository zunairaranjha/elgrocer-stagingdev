class AddRetailerServiceIdToDeliverySlot < ActiveRecord::Migration[4.2]
  def change
    add_column :delivery_slots, :retailer_service_id, :integer
    change_column_null :delivery_slots, :retailer_delivery_zone_id, true
  end
end
