class AddColumnsToSetting < ActiveRecord::Migration
  def change
    add_column :settings, :order_accept_duration, :integer, default: 15
    add_column :settings, :order_enroute_duration, :integer, default: 30
    add_column :settings, :order_delivered_duration, :integer, default: 60
  end
end
