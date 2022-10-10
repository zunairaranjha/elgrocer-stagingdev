class AddColumnsToRetailers < ActiveRecord::Migration
  def change
    add_column :retailers, :delivery_type_id, :integer, default: 0
    add_column :retailers, :delivery_slot_skip_hours, :integer, default: 14400 
    add_column :retailers, :schedule_order_reminder_hours, :integer, default: 3600 
  end
end
