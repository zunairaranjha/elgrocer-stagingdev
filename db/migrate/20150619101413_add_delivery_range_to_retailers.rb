class AddDeliveryRangeToRetailers < ActiveRecord::Migration
  def up
    unless column_exists? :retailers, :delivery_range
      add_column :retailers, :delivery_range, :integer, precision: 11, scale: 8
    end
  end

  def down
    remove_column :retailers, :delivery_range
  end
end
