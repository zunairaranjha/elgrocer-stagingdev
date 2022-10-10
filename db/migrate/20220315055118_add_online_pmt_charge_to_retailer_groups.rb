class AddOnlinePmtChargeToRetailerGroups < ActiveRecord::Migration[5.1]
  def change
    add_column :retailer_groups, :online_payment_charge, :float, :default => 0.0
    #Ex:- :default =>''
  end
end
