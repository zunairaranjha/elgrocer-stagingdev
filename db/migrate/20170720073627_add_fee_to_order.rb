class AddFeeToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :delivery_fee, :float
    add_column :orders, :rider_fee, :float
    add_column :orders, :service_fee, :float
    add_column :orders, :estimated_delivery_at, :datetime
  end
end
