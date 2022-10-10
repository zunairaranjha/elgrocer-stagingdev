class AddShowPendingOrderHoursToRetailers < ActiveRecord::Migration
  def change
    add_column :retailers, :show_pending_order_hours, :integer, default: 0
  end
end
