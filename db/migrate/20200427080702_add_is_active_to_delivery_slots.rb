class AddIsActiveToDeliverySlots < ActiveRecord::Migration
  def change
    add_column :delivery_slots, :is_active, :boolean, default: true
    add_column :delivery_slots, :retailer_id, :integer
  end
end
