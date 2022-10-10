class CreateRetailerHasServices < ActiveRecord::Migration[4.2]
  def change
    create_table :retailer_has_services do |t|
      t.integer :retailer_id
      t.integer :retailer_service_id
      t.integer :cutoff_time, :default => 0
      t.float :service_fee, :default => 0.0
      t.float :min_basket_value, :default => 0.0
      t.integer :delivery_slot_skip_time, default: 0
      t.boolean :is_active, :default => false
      t.integer :schedule_order_reminder_time, default: 3600

      t.timestamps null: false
    end
  end
end
