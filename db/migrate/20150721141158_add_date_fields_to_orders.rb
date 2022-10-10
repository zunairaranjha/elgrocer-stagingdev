class AddDateFieldsToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :approved_at, :datetime
    add_column :orders, :processed_at, :datetime
    add_column :orders, :accepted_at, :datetime
    add_column :orders, :updated_at, :datetime
  end

  def down
    remove_column :orders, :approved_at, :datetime
    remove_column :orders, :processed_at, :datetime
    remove_column :orders, :accepted_at, :datetime
    remove_column :orders, :updated_at, :datetime
  end
end
