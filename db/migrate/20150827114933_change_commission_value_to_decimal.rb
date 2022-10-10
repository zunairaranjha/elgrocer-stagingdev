class ChangeCommissionValueToDecimal < ActiveRecord::Migration
  def up
    change_column :retailers, :commission_value, :decimal, default: 0
    change_column :shops, :commission_value, :decimal
    change_column :order_positions, :commission_value, :decimal, default: 0
  end

  def down
    change_column :retailers, :commission_value, :integer, default: 0
    change_column :shops, :commission_value, :integer
    change_column :order_positions, :commission_value, :integer, default: 0
  end
end
