class AddDeviceTypeToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :device_type, :integer
  end
end
