class AddCommision < ActiveRecord::Migration
  def up
    add_column :retailers, :commission_value, :integer, default: 0
    add_column :products, :commission_value, :integer
    add_column :order_positions, :commission_value, :integer, default: 0
  end

  def down
    remove_column :retailers, :commission_value
    remove_column :products, :commission_value
    remove_column :order_positions, :commission_value
  end
end
