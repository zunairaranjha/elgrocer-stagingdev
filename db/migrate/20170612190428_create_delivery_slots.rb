class CreateDeliverySlots < ActiveRecord::Migration
  def change
    create_table :delivery_slots do |t|
      t.integer :day, null: false
      t.integer :start, null: false
      t.integer :end, null: false
      t.integer :retailer_delivery_zone_id, index: true, null: false
      t.integer :orders_limit, default: 0
    end
  end
end
