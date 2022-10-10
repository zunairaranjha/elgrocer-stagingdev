class AddIsActiveToRetailer < ActiveRecord::Migration
  def change
    add_column :retailers, :is_active, :bool, default: true
  end
end
