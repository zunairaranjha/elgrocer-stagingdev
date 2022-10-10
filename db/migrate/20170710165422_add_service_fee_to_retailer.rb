class AddServiceFeeToRetailer < ActiveRecord::Migration
  def change
    add_column :retailers, :service_fee, :float, default: 0
  end
end
