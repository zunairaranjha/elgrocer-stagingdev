class ChangeCommissionValue < ActiveRecord::Migration
  def up
    add_column :shops, :commission_value, :integer
    remove_column :products, :commission_value
  end

  def down
    add_column :products, :commission_value, :integer
    remove_column :shops, :commission_value
  end
end
